SELECT
    item_key,
    item_code,
    item_barcode,
    description AS item_description,
    category,
    department,
    sub_department,
    section,
    brand_name,
    count(DISTINCT store_key) AS stores_carrying_item  --Item-level calculation (how many stores stock this SKU)

FROM {{ ref('sale_data_cleaned') }}

GROUP BY item_key, item_code, item_barcode, item_description, category, department, sub_department, section, brand_name
ORDER BY category, sub_department, brand_name, item_code