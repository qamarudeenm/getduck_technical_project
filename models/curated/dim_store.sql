SELECT
    store_key,
    store_name AS store_name,
    count(DISTINCT sale_surrogate_key) AS total_transactions_recorded

FROM {{ ref('sale_data_cleaned') }}

GROUP BY store_key, store_name
ORDER BY store_name