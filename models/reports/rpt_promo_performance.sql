WITH promo_summary AS (
    SELECT
        f.item_key,
        d_i.brand_name,
        d_i.sub_department,
        
        SUM(quantity) AS total_units_sold,
        
        -- Promo-Specific Metrics
        SUM(CASE WHEN f.discount_depth_percent >= 0.10 THEN quantity ELSE 0 END) AS promo_units_sold,
        AVG(CASE WHEN f.discount_depth_percent >= 0.10 THEN realised_unit_price ELSE NULL END) AS promo_avg_unit_price,
        AVG(CASE WHEN f.discount_depth_percent < 0.10 THEN realised_unit_price ELSE NULL END) AS non_promo_avg_unit_price,
        AVG(CASE WHEN f.discount_depth_percent >= 0.10 THEN discount_depth_percent ELSE NULL END) AS avg_promo_discount_depth,
        
        -- Coverage: Count distinct stores that ran the promo
        COUNT(DISTINCT CASE WHEN f.discount_depth_percent >= 0.10 THEN store_key ELSE NULL END) AS stores_ran_promo_count,
        COUNT(DISTINCT f.store_key) AS total_stores_carrying

    FROM {{ ref('fact_sales_transaction') }} f
    JOIN {{ ref('dim_item') }} d_i ON f.item_key = d_i.item_key
    -- Only include items that had an actual promotional period (by definition of the promo inference logic)
    WHERE is_promotional_period_sku = TRUE 
    GROUP BY 1, 2, 3
)

SELECT
    s.item_key,
    s.brand_name,
    s.sub_department,
    s.total_units_sold,
    s.promo_units_sold,
    s.avg_promo_discount_depth,
    s.promo_avg_unit_price,
    s.non_promo_avg_unit_price,
    
    -- KPI 1: Promo Uplift % (Units)
    -- Formula: ( (Promo Units / Promo Days) - Baseline Avg ) / Baseline Avg
    ROUND(
        (
            (CAST(s.promo_units_sold AS Float64) / 7.0) - b.baseline_daily_units_avg
        ) / b.baseline_daily_units_avg,
        4
    ) AS promo_uplift_pct,
    
    -- KPI 2: Promo Coverage % (Stores running promo / Total stores carrying item)
    ROUND(
        CAST(s.stores_ran_promo_count AS Float64) / s.total_stores_carrying,
        4
    ) AS promo_coverage_pct

FROM promo_summary s
JOIN {{ ref('int_promo_baseline') }} b 
    ON s.item_key = b.item_key

ORDER BY promo_uplift_pct DESC