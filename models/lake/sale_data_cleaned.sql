
WITH base AS (
SELECT *
 FROM {{ ref('stg_raw_sales_data') }}
),

deduplicated_layer AS (
    -- Deduplicating records based on all columns
SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY TRIM(store_name), Item_code, Item_barcode, TRIM(description), TRIM(category), TRIM(department), TRIM(sub_department), TRIM(section), 
quantity, total_sales, RRP, supplier, date_of_sale
 ) row_num
FROM base
 WHERE length(trim(Item_code)) > 0

)
WHERE row_num = 1
ORDER BY row_num
),


pre_cleaned_metrics AS (
    SELECT
        *,
        toFloat64OrNull(quantity) AS quantity_num,
        toFloat64OrNull(total_sales) AS total_sales_num,
        toFloat64OrNull(RRP) AS rrp_num
    FROM deduplicated_layer
),


final_cleaned_data AS (
SELECT
    *
FROM pre_cleaned_metrics
-- Exclude record with negative quantity, total_sales, or RRP
WHERE 
        -- Filter 1: RRP must be a valid number AND positive
        rrp_num IS NOT NULL 
        AND rrp_num > 0
        
        -- Filter 2: Quantity and Sales must be positive (i.e., exclude <= 0)
        AND quantity_num > 0
        AND total_sales_num > 0

)

SELECT
    
    CAST(store_name AS String) AS store_name,
    CAST(Item_code AS String) AS item_code,
    CAST(Item_barcode AS String) AS item_barcode,
    CAST(description AS String) AS description,
    CAST(category AS String) AS category,
    CAST(department AS String) AS department,
    CAST(sub_department AS String) AS sub_department,
    CAST(section AS String) AS section,
    ROUND(quantity_num, 2) AS quantity,
    ROUND(total_sales_num, 2) AS total_sales,
    ROUND(rrp_num, 2) AS RRP,
    CAST(supplier AS String) AS supplier,
    CAST(date_of_sale AS Date) AS date_of_sale,
    date_of_sale_casted_for_partition
FROM final_cleaned_data
