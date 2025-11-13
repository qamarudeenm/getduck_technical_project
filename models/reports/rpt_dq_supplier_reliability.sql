WITH rejected_supplier_summary AS (
    -- 1. ACCEPTED (CLEAN) RECORDS
    SELECT
        t.supplier_key,
        t.store_key,
        FALSE AS is_rejected,
        CAST(1 AS Int64) AS total_record_count
    FROM {{ ref('fact_sales_transaction') }} t

    UNION ALL

    -- 2. REJECTED (BAD) RECORDS
    SELECT
        d_s.supplier_key,
        d_store.store_key,
        TRUE AS is_rejected,
        CAST(1 AS Int64) AS total_record_count
    FROM {{ ref('rejected_data_process') }} r -- Rejected records
    -- Join on attributes to map the raw rejected record to its dimension keys
    JOIN {{ ref('dim_supplier') }} d_s
        ON r.supplier = d_s.supplier_name
    JOIN {{ ref('dim_store') }} d_store
        ON r.store_name = d_store.store_name
),

dq_by_supplier_and_store AS (
    -- Group and aggregate counts
    SELECT
        rs.supplier_key,
        d_s.supplier_name,
        rs.store_key,
        d_store.store_name,
        SUM(total_record_count) AS total_records_processed,
        SUM(CASE WHEN is_rejected THEN total_record_count ELSE 0 END) AS total_rejected_records,
        
        -- Key Metric: Rejection Rate for the entity
        ROUND(
            CAST(SUM(CASE WHEN is_rejected THEN total_record_count ELSE 0 END) AS Float64) / SUM(total_record_count),
            4
        ) AS rejection_rate
    FROM rejected_supplier_summary rs
    JOIN {{ ref('dim_supplier') }} d_s ON rs.supplier_key = d_s.supplier_key
    JOIN {{ ref('dim_store') }} d_store ON rs.store_key = d_store.store_key
    GROUP BY 1, 2, 3, 4
)

SELECT
    *,
    CASE 
        WHEN total_records_processed > 100 AND rejection_rate >= 0.05 THEN TRUE
        ELSE FALSE 
    END AS is_flagged_unreliable

FROM dq_by_supplier_and_store
ORDER BY rejection_rate DESC