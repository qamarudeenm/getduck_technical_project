import pandas as pd
import hashlib
from clickhouse_connect import get_client
from clickhouse_connect.driver.client import Client
from datetime import datetime, time, timezone


# --- DB Configuration (Matches docker-compose) ---
CH_HOST = 'clickhouse'
CH_PORT = 8123
CH_DATABASE = 'getduck_project'
CH_USER='default'
CH_PASSWORD='default'

# ALL SCHEMAS DEFINED IN dbt_project.yml
SCHEMAS_TO_CREATE = ['getduck_project','raw', 'lake', 'curated', 'reports', 'rejected'] 

def create_client() -> Client:
    """Initializes and returns the ClickHouse client with credentials."""
    return get_client(
        host=CH_HOST, 
        port=CH_PORT, 
        database=CH_DATABASE,
        username=CH_USER,
        password=CH_PASSWORD
    )

def setup_database(client: Client):
    """Creates all schemas/databases necessary for the dbt project."""
    print(f"Creating project schemas in ClickHouse...")
    for schema_name in SCHEMAS_TO_CREATE:
        print(f"  -> Creating schema: {schema_name}")
        # ClickHouse uses 'DATABASE' command, which is analogous to a schema/namespace
        client.command(f"CREATE DATABASE IF NOT EXISTS {schema_name}")
    print("All schemas initialized successfully.")

def create_staging_table(client: Client):
    """Creates the raw staging table if it doesn't exist, and ensures row_hash column is present."""
    STAGING_SCHEMA = 'getduck_project'
    STAGING_TABLE = 'raw_wkly_data'
    
    print(f"Creating staging table {STAGING_SCHEMA}.{STAGING_TABLE}...")
    
    # Define the table schema. We use String for most raw columns to avoid errors
    # during ingestion. Type casting should be handled later in dbt (curated layer).
    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS {STAGING_SCHEMA}.{STAGING_TABLE}
    (
        `store_name` String,
        `item_code` String,
        `item_barcode` String,
        `description` String,
        `category` String,
        `department` String,
        `sub_department` String,
        `section` String,
        `quantity` String,
        `total_sales` String,
        `RRP` String,
        `supplier` String,
        `date_of_sale` String,
        `row_hash` String
    )
    ENGINE = log
    """
    
    client.command(create_table_query)
    
    # Check if row_hash column exists, add it if it doesn't
    try:
        # Try to query the row_hash column
        client.query(f"SELECT row_hash FROM {STAGING_SCHEMA}.{STAGING_TABLE} LIMIT 1")
        print("Staging table verified with row_hash column.")
    except Exception as e:
        if "UNKNOWN_IDENTIFIER" in str(e) or "Unknown expression identifier" in str(e):
            print("⚠ row_hash column missing. Adding it to existing table...")
            # Add the row_hash column to the existing table
            alter_query = f"ALTER TABLE {STAGING_SCHEMA}.{STAGING_TABLE} ADD COLUMN IF NOT EXISTS `row_hash` String"
            client.command(alter_query)
            print("✓ row_hash column added successfully.")
        else:
            # Re-raise if it's a different error
            raise
    
    print("Staging table created successfully.")

def generate_row_hash(row_dict):
    """Generate MD5 hash from row data for deduplication."""
    # Create a stable string representation of the row
    # Sort keys to ensure consistent hash generation
    row_str = '|'.join(str(row_dict.get(col, '')) for col in sorted(row_dict.keys()))
    return hashlib.md5(row_str.encode()).hexdigest()

def load_data(client: Client):
    """Loads the CSV data into the staging table, avoiding duplicates."""
    STAGING_SCHEMA = 'getduck_project'
    STAGING_TABLE = 'raw_wkly_data'
    CSV_PATH = 'data/getduck_raw_data.csv'
    COLUMN_MAPPING = {
    "Store Name": "store_name",
    "Item_Code": "item_code",
    "Item Barcode": "item_barcode",
    "Description": "description",
    "Category": "category",
    "Department": "department",
    "Sub-Department": "sub_department",
    "Section": "section",
    "Quantity": "quantity",
    "Total Sales": "total_sales",
    "RRP": "RRP",
    "Supplier": "supplier",
    "Date Of Sale": "date_of_sale"
}
    print(f"Loading {CSV_PATH} into {STAGING_SCHEMA}.{STAGING_TABLE}...")
    
    # Read CSV, forcing all fields to string (text) to handle messy raw format
    df = pd.read_csv(CSV_PATH, dtype=str)
    df = df.fillna('') # TO FIX NULL ISSUES DURING INSERTION

    def clean_header(col):
        return COLUMN_MAPPING.get(col.strip(), col)
        
    df.columns = [clean_header(col) for col in df.columns]

    # Generate hash for each row for deduplication
    print("Generating row hashes for deduplication...")
    df['row_hash'] = df.apply(lambda row: generate_row_hash(row.to_dict()), axis=1)
    
    # Get existing hashes from database to avoid duplicates
    existing_hashes = set()
    try:
        print("Checking for existing data in database...")
        # Only get non-empty hashes (in case column was just added to existing data)
        result = client.query(f"SELECT DISTINCT row_hash FROM {STAGING_SCHEMA}.{STAGING_TABLE} WHERE row_hash != ''")
        existing_hashes = {row[0] for row in result.result_rows}
        print(f"Found {len(existing_hashes)} existing unique rows in database")
    except Exception as e:
        print(f"Note: Could not fetch existing hashes (table might be empty): {e}")
    
    # Filter to only new rows
    new_rows_df = df[~df['row_hash'].isin(existing_hashes)]
    
    if len(new_rows_df) == 0:
        print("✓ No new data to load. All rows already exist in the database.")
        return
    
    print(f"Found {len(new_rows_df)} new rows out of {len(df)} total rows in CSV")
    print(f"Inserting {len(new_rows_df)} new records...")
    
    # Use client.insert_df to load only the new dataframe
    client.insert_df(
        table=STAGING_TABLE,
        database=STAGING_SCHEMA,
        df=new_rows_df
    )
    print(f"✓ Successfully loaded {len(new_rows_df)} new records.")

if __name__ == '__main__':
    try:
        client = create_client()
        setup_database(client)
        create_staging_table(client)
        load_data(client)
    except Exception as e:
        print(f"Database initialization failed: {e}")