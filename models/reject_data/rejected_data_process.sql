WITH source_data AS (
    SELECT *
    FROM (
        SELECT
            *,
            toFloat64OrNull(quantity) AS quantity_num,
            toFloat64OrNull(total_sales) AS total_sales_num,
            toFloat64OrNull(RRP) AS rrp_num
        FROM (
            SELECT 
                *,
                ROW_NUMBER() OVER(PARTITION BY 
                    TRIM(store_name), item_code, item_barcode, TRIM(description), 
                    TRIM(category), TRIM(department), TRIM(sub_department), 
                    TRIM(section), quantity, total_sales, RRP, supplier, date_of_sale
                ) AS row_num
            FROM {{ ref('stg_raw_sales_data') }} -- Reference the raw staging layer
            WHERE length(trim(item_code)) > 0
        )
        WHERE row_num = 1
    )
),

rejection_flags AS (
    SELECT
        *,
        (quantity_num IS NULL OR quantity_num <= 0) AS is_negative_quantity,
        (total_sales_num IS NULL OR total_sales_num <= 0) AS is_negative_sales,
        (rrp_num IS NULL OR rrp_num <= 0) AS is_invalid_rrp,
         -- Catches the extreme high value for logging **
        (total_sales_num > 52000) AS is_extreme_sales_outlier,
        (is_negative_quantity OR is_negative_sales OR is_invalid_rrp OR is_extreme_sales_outlier) AS is_rejected
        
    FROM source_data
),

final_rejected_data AS (
    SELECT
        store_name,
        item_code,
        item_barcode,
        description,
        category,
        department,
        sub_department,
        section,
        quantity,
        total_sales,  
        RRP,
        supplier,
        date_of_sale,
        date_of_sale_casted_for_partition,
        
        multiIf(
            is_extreme_sales_outlier, 'REJECTED: Extreme Sales Outlier (> 52000)',
            is_invalid_rrp, 'REJECTED: Invalid (NULL/Zero/Negative) RRP',
            is_negative_sales, 'REJECTED: Non-Positive Total Sales Value',
            is_negative_quantity, 'REJECTED: Non-Positive Quantity',
            'ERROR: Should not happen'
        ) AS rejection_reason

    FROM rejection_flags
    -- SELECT ONLY the records that failed the quality checks
    WHERE is_rejected = TRUE
)

SELECT * FROM final_rejected_data