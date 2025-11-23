WITH base AS (
SELECT *
 FROM {{ ref('stg_raw_sales_data') }}
),

deduplicated_layer AS (
    -- Deduplicating records based on all columns
SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY TRIM(store_name), item_code, item_barcode, TRIM(description), TRIM(category), TRIM(department), TRIM(sub_department), TRIM(section), 
quantity, total_sales, RRP, supplier, date_of_sale
 ) row_num
FROM base
 WHERE length(trim(item_code)) > 0

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
        UPPER(TRIM(CAST(store_name AS String))) AS store_name,
        UPPER(TRIM(CAST(item_code AS String))) AS item_code,
        UPPER(TRIM(CAST(item_barcode AS String))) AS item_barcode,
        UPPER(TRIM(CAST(description AS String))) AS description,
        UPPER(TRIM(CAST(category AS String))) AS category,
        UPPER(TRIM(CAST(department AS String))) AS department,
        UPPER(TRIM(CAST(sub_department AS String))) AS sub_department,
        UPPER(TRIM(CAST(section AS String))) AS section,
        UPPER(TRIM(CAST(supplier AS String))) AS supplier,
        CAST(date_of_sale AS Date) AS date_of_sale,
        CAST(date_of_sale AS Date) AS date_of_sale_casted_for_partition,
        quantity_num,
        total_sales_num,
        rrp_num
    FROM pre_cleaned_metrics
    WHERE 
            -- RRP must be a valid number AND positive
            rrp_num IS NOT NULL 
            AND rrp_num > 0
            
            -- Quantity and Sales must be positive (i.e., exclude <= 0)
            AND quantity_num > 0
            AND total_sales_num > 0
            -- EXCLUDE EXTREME TOTAL SALES OUTLIERS **
            -- This is based on observed data gap to remove the single (75,862.06) outlier.
            -- while retaining the next highest bulk sales (51,681.00 and below).
            AND total_sales_num <= 52000 

),

sales_with_metrics AS (
    SELECT
        *,
        ROUND(total_sales_num / quantity_num, 2) AS realised_unit_price,
        ROUND((rrp_num - (total_sales_num / quantity_num)) / rrp_num, 2) AS discount_depth_percent,
        toStartOfWeek(date_of_sale) AS week_start_date 
    FROM final_cleaned_data
),

promo_week_status AS (
    SELECT 
        *, 
        
        -- Window function to count distinct days where the item was deeply discounted
        COUNT(DISTINCT 
            CASE 
                WHEN discount_depth_percent >= 0.10 THEN date_of_sale 
                ELSE NULL 
            END
        ) OVER (PARTITION BY item_code, week_start_date) AS total_distinct_promo_days
        
    FROM sales_with_metrics 

),

final_projection AS (
    SELECT
        *,         
        -- Set the 'is_promotional_period_sku' flag
        CASE
            WHEN total_distinct_promo_days >= 2 THEN TRUE
            ELSE FALSE
        END AS is_promotional_period_sku
        
    FROM promo_week_status

)



SELECT
    {{ dbt_utils.generate_surrogate_key(['store_name']) }} AS store_key,
    {{ dbt_utils.generate_surrogate_key(['supplier']) }} AS supplier_key,
    {{ dbt_utils.generate_surrogate_key(['item_code', 'sub_department', 'section']) }} AS item_key,
    {{ dbt_utils.generate_surrogate_key([
            'store_name', 'item_code', 'item_barcode', 'description', 'category', 'department', 'sub_department', 'section',  
            'quantity_num', 'total_sales_num', 'rrp_num', 'supplier', 'date_of_sale'
        ]) }} AS sale_surrogate_key,
    {{ dbt_utils.generate_surrogate_key(['sub_department', 'section', 'store_name']) }} AS competitive_set_key,   -- for Pricing Index in window functions
    store_name,
    item_code,
    item_barcode,
    description,
    category,
    department,
    sub_department,
    section,  
    supplier,
    CASE 
        WHEN supplier = 'BIDCO AFRICA LIMITED' THEN TRUE ELSE FALSE 
        END AS is_bidco_sku,    -- client-specific business logic (calculated column)
    CASE
        WHEN UPPER(TRIM(description)) LIKE 'WS-%' THEN TRUE
        WHEN quantity_num >= 20 THEN TRUE 
        WHEN total_sales_num > 10000 THEN TRUE
        ELSE FALSE
    END AS is_wholesale_bulk,  -- business logic to flag wholesale/bulk sales (calculated column)

    CASE
    -- BIDCO AFRICA BRANDS (Supplier is 'BIDCO AFRICA LIMITED' or a known subsidiary/related entity)

    -- Ribena / Lucozade (SFB / SBF)
    WHEN description LIKE 'FD-SFB-RIBENA%' OR description LIKE 'FD-SBF RIBENA%' THEN 'RIBENA'
    WHEN description LIKE 'FD-SBF LUCOZADE%' THEN 'LUCOZADE'

    -- Cooking Oils (Golden Fry, Elianto, Kimbo, Sun Gold)
    WHEN description LIKE '%GOLDEN FRY%' THEN 'GOLDEN FRY'
    WHEN description LIKE '%ELIANTO%' THEN 'ELIANTO'
    WHEN description LIKE '%KIMBO PREMIUM OIL%' OR description LIKE '%KIMBO COOKING FAT%' THEN 'KIMBO'
    WHEN description LIKE '%SUN GOLD SEED OIL%' THEN 'SUN GOLD'
    WHEN description LIKE '%OLIVE GOLD%' THEN 'OLIVE GOLD'
    
    -- Margarine/Fats (Gold Band, Cowboy, Chipsy)
    WHEN description LIKE '%GOLD BAND MARGARINE%' THEN 'GOLD BAND'
    WHEN description LIKE '%COWBOY SPESHELI%' THEN 'COWBOY'
    WHEN description LIKE '%CHIPSY COOKING FAT%' THEN 'CHIPSY'

    -- Detergents (Msafi, White Star, Whitestar)
    WHEN description LIKE '%MSAFI%' OR description LIKE '%MSAAFI%' THEN 'MSAFI'
    WHEN description LIKE '%WHITESTAR BAR SOAP%' OR description LIKE '%BID WHITESTAR%' THEN 'WHITESTAR'

    -- Cereals / Snacks (Shapies, Fillows, Sun Top, Noodies, E&N Chipstick)
    WHEN description LIKE '%SHAPIES%' OR description LIKE '%FILLOWS%' THEN 'SHAPIES/FILLOWS CEREAL'
    WHEN description LIKE '%SUN TOP%' THEN 'SUN TOP'
    WHEN description LIKE '%NOODIES%' THEN 'NOODIES'
    WHEN description LIKE '%E&N CHIPSTICK%' THEN 'E&N CHIPSTICK'
    WHEN description LIKE '%MARIANDAZI BAKING%' THEN 'MARIANDAZI' -- Baking
    WHEN description LIKE '%MULTIGRAIN WAVY CHIPS%' THEN 'MULTIGRAIN'
    WHEN description LIKE '%JUO MANGO%' THEN 'JUO'
    
    -- comparison works against competitive set
    WHEN description LIKE '%FANTA%' THEN 'FANTA'
    WHEN description LIKE '%SPRITE%' THEN 'SPRITE'
    WHEN description LIKE '%COCA%COLA%' OR description LIKE '%COKE%' THEN 'COCA-COLA'
    WHEN description LIKE '%ARIEL%' THEN 'ARIEL'
    WHEN description LIKE '%OMO%' THEN 'OMO'
    WHEN description LIKE '%JIK%' THEN 'JIK'
    WHEN description LIKE '%WEETABIX%' THEN 'WEETABIX'
    WHEN description LIKE '%LUCOZADE%' THEN 'LUCOZADE'
    WHEN description LIKE '%MINUTE MAID%' THEN 'MINUTE MAID'
    WHEN description LIKE '%CADBURY%' THEN 'CADBURY'
    WHEN description LIKE '%KAP RINA%' THEN 'KAP RINA' -- Main Oil Competitor
    WHEN description LIKE '%SALIT%' THEN 'SALIT' -- Main Oil Competitor
    ELSE UPPER(TRIM(supplier)) -- Use the cleaned Supplier Name
    END AS brand_name,
    is_promotional_period_sku,
    -- value metrics
    ROUND(quantity_num, 2) AS quantity,
    ROUND(total_sales_num, 2) AS total_sales,
    ROUND(rrp_num, 2) AS RRP,
    ROUND(total_sales_num / quantity_num, 2) AS realised_unit_price,     -- actual price paid per unit (calculated column)
    ROUND((rrp_num - realised_unit_price) / rrp_num, 2) AS discount_depth_percent,  -- discount depth as a percentage (calculated column) 

    CAST(date_of_sale AS Date) AS date_of_sale,
    toDayOfWeek(date_of_sale) AS day_of_week,  -- 1=Monday, 7=Sunday
    toStartOfWeek(date_of_sale) AS week_start_date,
    toYYYYMMDD(date_of_sale) AS date_key_int, -- For relational joins
    date_of_sale_casted_for_partition
FROM final_projection
