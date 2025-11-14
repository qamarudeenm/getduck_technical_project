import uvicorn
from fastapi import FastAPI
from typing import List, Dict
from clickhouse_connect import get_client
import time
import pandas as pd

app = FastAPI()

# --- DB Configuration (Matches docker-compose) ---
CH_HOST = 'clickhouse'
CH_PORT = 8123
CH_DATABASE = 'reports'
CH_USER='default'
CH_PASSWORD='default'
# -----------------------------------------------

def query_ch_df(query: str) -> pd.DataFrame:
    """Connects to ClickHouse and returns query result as a DataFrame."""
    # Add a retry mechanism for robustness in Docker startup
    client = None
    for _ in range(5):
        try:
            client = get_client(host=CH_HOST, port=CH_PORT, database=CH_DATABASE, username=CH_USER,password=CH_PASSWORD)
            if client.ping():
                 break
        except Exception:
            time.sleep(2)
            continue
    if not client:
        raise ConnectionError("Failed to connect to ClickHouse after multiple retries.")
        
    return client.query_df(query)

@app.get("/data-health/overall", response_model=Dict)
def get_overall_health():
    """Returns the overall data acceptance rate and rejection details."""
    query = f"SELECT total_accepted_records, total_rejected_records, data_acceptance_rate, arrayConcat(all_rejection_reasons) FROM reports.rpt_data_volume_acceptance"
    df = query_ch_df(query)
    
    # Return as dict from the single row DataFrame
    return df.iloc[0].to_dict()

@app.get("/promotions/uplift", response_model=List[Dict])
def get_promo_uplift_ranking():
    """Returns data for the Promo Uplift Ranking chart (Top 10)."""
    query = f"""
                SELECT
                    d_i.brand_name,
                    d_i.sub_department,
                    max(p.promo_uplift_pct) as promo_uplift_pct,
                    argMax(p.promo_coverage_pct, p.promo_uplift_pct) as promo_coverage_pct
                FROM reports.rpt_promo_performance p
                INNER JOIN curated.dim_item d_i ON p.item_key = d_i.item_key
                GROUP BY
                    d_i.brand_name,
                    d_i.sub_department
                ORDER BY
                    promo_uplift_pct DESC
                LIMIT 10
    """
    df = query_ch_df(query)
    return df.to_dict('records')

@app.get("/pricing-index/positioning", response_model=List[Dict])
def get_pricing_positioning():
    """Returns data for the Pricing Index (Bidco only)."""
    query = f"""
                SELECT
                    r.brand_name,
                    r.store_name,
                    r.sub_department,
                    r.section,
                    r.realised_unit_price,
                    r.peer_avg_unit_price,
                    r.peer_price_index,
                    r.price_positioning
                FROM rpt_pricing_index_detail r
                WHERE r.is_bidco_supplier = True
                ORDER BY r.peer_price_index ASC
            """
    df = query_ch_df(query)
    return df.to_dict('records')

@app.get("/supplier/reliability", response_model=List[Dict])
def get_supplier_reliability():
    """
    Endpoint: GET /supplier/reliability
    Underlying Report: rpt_dq_supplier_reliability
    Description: This endpoint would provide a detailed breakdown of data quality issues per supplier. It could list suppliers with the highest number of
      rejected records, the most common rejection reasons, and their overall data acceptance rate. This helps in identifying unreliable data sources and
      working with suppliers to improve data quality.
    """
    query = f"""
                SELECT rps.supplier_name,
                    SUM(total_rejected_records) AS supplier_total_rejected_records,
                    rdp.rejection_reason
                    FROM reports.rpt_dq_supplier_reliability rps
                    left join rejected.rejected_data_process rdp 
                    on rps.supplier_name = rdp.supplier 
                WHERE total_rejected_records > 0
                GROUP BY rps.supplier_name, rdp.rejection_reason
                ORDER BY supplier_total_rejected_records DESC
            """
    df = query_ch_df(query)
    return df.to_dict('records')


@app.get("/promotions/performance/details", response_model=List[Dict])
def get_promo_performance_details(brand_name: str = None, sub_department: str = None):
    """
    Endpoint: GET /promotions/performance/details
    Underlying Report: rpt_promo_performance
    Description: This could provide a more granular view than the current /promotions/uplift endpoint. It could accept query parameters to filter by
      brand_name or sub_department and return detailed performance metrics like promo_sales_volume, baseline_sales_volume, and avg_promo_discount_depth for
      specific items, allowing for a deeper dive into what drives a promotion's success or failure.
    """
    query = f"""
                SELECT
                    p.brand_name,
                    p.sub_department,
                    p.item_key,
                    p.promo_sales_volume,
                    p.baseline_sales_volume,
                    p.avg_promo_discount_depth
                FROM rpt_promo_performance p
                INNER JOIN curated.dim_item d_i ON p.item_key = d_i.item_key
                WHERE 1=1
            """
    if brand_name:
        query += f" AND p.brand_name = '{brand_name}'"
    if sub_department:
        query += f" AND p.sub_department = '{sub_department}'"
    
    query += " ORDER BY p.promo_sales_volume DESC"

    df = query_ch_df(query)
    return df.to_dict('records')


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)