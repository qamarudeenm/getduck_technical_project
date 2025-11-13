SELECT
    competitive_set_key,
    sub_department,
    section,
    store_name,
    COUNT(DISTINCT supplier_key) AS total_suppliers_in_set

FROM {{ ref('sale_data_cleaned') }}

GROUP BY competitive_set_key, sub_department, section, store_name
ORDER BY store_name, sub_department, section