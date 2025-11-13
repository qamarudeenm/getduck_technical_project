WITH acceptance_data AS (
    SELECT
        COUNT(DISTINCT sale_surrogate_key) AS total_accepted_records
    FROM {{ ref('fact_sales_transaction') }}
),

rejection_data AS (
    SELECT
        COUNT(*) AS total_rejected_records,
        groupArray(DISTINCT rejection_reason) AS all_rejection_reasons 
    FROM {{ ref('rejected_data_process') }}
),

final_report AS (
    SELECT
        a.total_accepted_records,
        r.total_rejected_records,
        a.total_accepted_records + r.total_rejected_records AS total_raw_records,
        
        -- Data Acceptance Rate
        ROUND(
            CAST(a.total_accepted_records AS Float64) / (a.total_accepted_records + r.total_rejected_records), 
            2
        ) AS data_acceptance_rate,
        r.all_rejection_reasons

    FROM acceptance_data a
    CROSS JOIN rejection_data r  -- Cross join works as each CTE returns one row
)

SELECT * FROM final_report