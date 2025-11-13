SELECT
    supplier_key,
    supplier AS supplier_name,
    max(is_bidco_sku) AS is_bidco_supplier,  -- Use MAX to ensure TRUE if any sale flagged it as Bidco
    count(DISTINCT item_code) AS total_distinct_skus_supplied

FROM {{ ref('sale_data_cleaned') }}

GROUP BY supplier_key, supplier_name
ORDER BY is_bidco_supplier DESC, supplier_name