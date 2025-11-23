SELECT
    item_key,
    item_code,
    -- item_barcode removed to ensure one row per item_key (prevents cartesian product)
    any(description) AS item_description,  -- Pick any description (same item may have variations)
    category,
    department,
    sub_department,
    section,
    any(brand_name) AS brand_name,  -- Pick any brand (same item may have multiple suppliers)
    count(DISTINCT store_key) AS stores_carrying_item  --Item-level calculation (how many stores stock this SKU)

FROM {{ ref('sale_data_cleaned') }}

GROUP BY item_key, item_code, category, department, sub_department, section
ORDER BY category, sub_department, item_code