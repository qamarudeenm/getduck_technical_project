WITH non_promo_sales AS (
    SELECT
        item_key,
        date_key_int,
        SUM(quantity) AS daily_units_sold
    FROM {{ ref('fact_sales_transaction') }}
    -- Filter out any day considered part of a promotional period SKU
    WHERE is_promotional_period_sku = FALSE 
    GROUP BY 1, 2
)

SELECT
    item_key,
    -- Calculate the average daily unit sales across all non-promo days
    ROUND(AVG(daily_units_sold), 4) AS baseline_daily_units_avg,
    COUNT(date_key_int) AS total_baseline_days

FROM non_promo_sales
GROUP BY 1