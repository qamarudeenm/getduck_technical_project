ATTACH VIEW _ UUID '80ffbd91-d9d5-4ad1-afe4-3cd51700a890'
(
    `rs.supplier_key` String,
    `supplier_name` String,
    `rs.store_key` String,
    `store_name` String,
    `total_records_processed` Int64,
    `total_rejected_records` Int64,
    `rejection_rate` Float64,
    `is_flagged_unreliable` Bool
)
AS WITH
    rejected_supplier_summary AS
    (
        SELECT
            t.supplier_key,
            t.store_key,
            false AS is_rejected,
            CAST(1, 'Int64') AS total_record_count
        FROM curated.fact_sales_transaction AS t
        UNION ALL
        SELECT
            d_s.supplier_key,
            d_store.store_key,
            true AS is_rejected,
            CAST(1, 'Int64') AS total_record_count
        FROM rejected.rejected_data_process AS r
        INNER JOIN curated.dim_supplier AS d_s ON r.supplier = d_s.supplier_name
        INNER JOIN curated.dim_store AS d_store ON r.store_name = d_store.store_name
    ),
    dq_by_supplier_and_store AS
    (
        SELECT
            rs.supplier_key,
            d_s.supplier_name,
            rs.store_key,
            d_store.store_name,
            sum(total_record_count) AS total_records_processed,
            sum(multiIf(is_rejected, total_record_count, 0)) AS total_rejected_records,
            round(CAST(sum(multiIf(is_rejected, total_record_count, 0)), 'Float64') / sum(total_record_count), 4) AS rejection_rate
        FROM
        rejected_supplier_summary AS rs
        INNER JOIN curated.dim_supplier AS d_s ON rs.supplier_key = d_s.supplier_key
        INNER JOIN curated.dim_store AS d_store ON rs.store_key = d_store.store_key
        GROUP BY
            1,
            2,
            3,
            4
    )
SELECT
    *,
    multiIf((total_records_processed > 100) AND (rejection_rate >= 0.05), true, false) AS is_flagged_unreliable
FROM
dq_by_supplier_and_store
ORDER BY rejection_rate DESC
