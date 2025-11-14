ATTACH VIEW _ UUID 'f0090e15-15f3-4453-9e58-7de27cc8d04b'
(
    `total_accepted_records` UInt64,
    `total_rejected_records` UInt64,
    `total_raw_records` UInt64,
    `data_acceptance_rate` Float64,
    `all_rejection_reasons` Array(String)
)
AS WITH
    acceptance_data AS
    (
        SELECT COUNTDistinct(sale_surrogate_key) AS total_accepted_records
        FROM curated.fact_sales_transaction
    ),
    rejection_data AS
    (
        SELECT
            count(*) AS total_rejected_records,
            groupArrayDistinct(rejection_reason) AS all_rejection_reasons
        FROM rejected.rejected_data_process
    ),
    final_report AS
    (
        SELECT
            a.total_accepted_records,
            r.total_rejected_records,
            a.total_accepted_records + r.total_rejected_records AS total_raw_records,
            round(CAST(a.total_accepted_records, 'Float64') / (a.total_accepted_records + r.total_rejected_records), 2) AS data_acceptance_rate,
            r.all_rejection_reasons
        FROM
        acceptance_data AS a
        CROSS JOIN
        rejection_data AS r
    )
SELECT *
FROM
final_report
