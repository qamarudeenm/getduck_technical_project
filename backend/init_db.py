import pandas as pd
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
    """Creates the raw staging table if it doesn't exist."""
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
        `date_of_sale` String
                )
    ENGINE = log
    """
    
    client.command(create_table_query)
    print("Staging table created successfully.")

def load_data(client: Client):
    """Loads the CSV data into the staging table."""
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

    def to_datetime_midnight(date_str):
        # Handle the two date formats seen in the original sample data ('23/09/2025' and '23/09/2025')
        try:
            dt = datetime.strptime(date_str, '%Y/%m/%d').date()
        except ValueError:
            if date_str and date_str.strip(): # Only print warning for non-empty, invalid strings
                 print(f"Warning: Unexpected date format encountered: {date_str}")
            return None
        return datetime.combine(dt, time(0, 0, 0)) # Set to Midnight

    # df['date_of_sale_casted_for_partition'] = df['date_of_sale'].apply(to_datetime_midnight)

    # Use client.insert_df to load the dataframe
    client.insert_df(
        table=STAGING_TABLE,
        database=STAGING_SCHEMA,
        df=df

    )
    print("Data loaded successfully.")

if __name__ == '__main__':
    try:
        client = create_client()
        setup_database(client)
        create_staging_table(client)
        load_data(client)
    except Exception as e:
        print(f"Database initialization failed: {e}")