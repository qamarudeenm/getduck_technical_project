ATTACH VIEW _ UUID '63c721d8-b2c0-4e07-a5fd-b00784b754a2'
(
    `item_key` String,
    `brand_name` String,
    `sub_department` String,
    `total_units_sold` Nullable(Float64),
    `promo_units_sold` Nullable(Float64),
    `promo_sales_volume` Nullable(Float64),
    `baseline_sales_volume` Nullable(Float64),
    `round(avg_promo_discount_depth, 2)` Nullable(Float64),
    `promo_avg_unit_price` Nullable(Float64),
    `non_promo_avg_unit_price` Nullable(Float64),
    `promo_uplift_pct` Nullable(Float64),
    `promo_coverage_pct` Float64
)
AS WITH promo_summary AS
    (
        SELECT
            f.item_key,
            d_i.brand_name,
            d_i.sub_department,
            sum(quantity) AS total_units_sold,
            sum(multiIf(f.discount_depth_percent >= 0.1, quantity, 0)) AS promo_units_sold,
            avg(multiIf(f.discount_depth_percent >= 0.1, realised_unit_price, NULL)) AS promo_avg_unit_price,
            avg(multiIf(f.discount_depth_percent < 0.1, realised_unit_price, NULL)) AS non_promo_avg_unit_price,
            avg(multiIf(f.discount_depth_percent >= 0.1, discount_depth_percent, NULL)) AS avg_promo_discount_depth,
            COUNTDistinct(multiIf(f.discount_depth_percent >= 0.1, store_key, NULL)) AS stores_ran_promo_count,
            COUNTDistinct(f.store_key) AS total_stores_carrying
        FROM curated.fact_sales_transaction AS f
        INNER JOIN curated.dim_item AS d_i ON f.item_key = d_i.item_key
        WHERE is_promotional_period_sku = true
        GROUP BY
            1,
            2,
            3
    )
SELECT
    s.item_key,
    s.brand_name,
    s.sub_department,
    s.total_units_sold,
    s.promo_units_sold,
    s.promo_units_sold * s.promo_avg_unit_price AS promo_sales_volume,
    b.baseline_daily_units_avg AS baseline_sales_volume,
    round(s.avg_promo_discount_depth, 2),
    s.promo_avg_unit_price,
    s.non_promo_avg_unit_price,
    round(((CAST(s.promo_units_sold, 'Float64') / 7.) - b.baseline_daily_units_avg) / b.baseline_daily_units_avg, 4) AS promo_uplift_pct,
    round(CAST(s.stores_ran_promo_count, 'Float64') / s.total_stores_carrying, 4) AS promo_coverage_pct
FROM
promo_summary AS s
INNER JOIN curated.int_promo_baseline AS b ON s.item_key = b.item_key
ORDER BY promo_uplift_pct DESC
