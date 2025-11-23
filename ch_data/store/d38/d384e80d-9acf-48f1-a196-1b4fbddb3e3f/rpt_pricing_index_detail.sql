ATTACH VIEW _ UUID '60132b2b-4605-4f8b-96d2-8822a7317d59'
(
    `item_key` String,
    `store_key` String,
    `competitive_set_key` String,
    `store_name` String,
    `sub_department` String,
    `section` String,
    `brand_name` String,
    `is_bidco_supplier` Bool,
    `realised_unit_price` Nullable(Float64),
    `RRP` Nullable(Float64),
    `discount_depth_percent` Nullable(Float64),
    `peer_avg_unit_price` Nullable(Float64),
    `peer_price_index` Nullable(Float64),
    `price_positioning` String
)
AS WITH
    sales_context AS
    (
        SELECT
            f.item_key AS item_key,
            f.store_key AS store_key,
            f.realised_unit_price AS realised_unit_price,
            f.RRP AS RRP,
            f.discount_depth_percent AS discount_depth_percent,
            d_c.competitive_set_key AS competitive_set_key,
            d_c.sub_department AS sub_department,
            d_c.section AS section,
            d_c.store_name AS store_name,
            d_i.brand_name AS brand_name,
            d_s.is_bidco_supplier AS is_bidco_supplier
        FROM curated.fact_sales_transaction AS f
        INNER JOIN curated.dim_competitive_set AS d_c ON f.competitive_set_key = d_c.competitive_set_key
        INNER JOIN curated.dim_supplier AS d_s ON f.supplier_key = d_s.supplier_key
        INNER JOIN curated.dim_item AS d_i ON f.item_key = d_i.item_key
    ),
    price_indexing AS
    (
        SELECT
            *,
            round(avg(multiIf(is_bidco_supplier = false, realised_unit_price, NULL)) OVER (PARTITION BY competitive_set_key), 2) AS peer_avg_unit_price
        FROM
        sales_context
    ),
    final_price_index AS
    (
        SELECT
            item_key,
            store_key,
            competitive_set_key,
            store_name,
            sub_department,
            section,
            brand_name,
            is_bidco_supplier,
            realised_unit_price,
            RRP,
            discount_depth_percent,
            peer_avg_unit_price,
            multiIf((peer_avg_unit_price IS NULL) OR (peer_avg_unit_price = 0), NULL, round(realised_unit_price / peer_avg_unit_price, 4)) AS peer_price_index,
            multiIf(realised_unit_price > (peer_avg_unit_price * 1.1), 'PREMIUM (10%+ High)', realised_unit_price < (peer_avg_unit_price * 0.9), 'DISCOUNT (10%+ Low)', (realised_unit_price >= (peer_avg_unit_price * 0.9)) AND (realised_unit_price <= (peer_avg_unit_price * 1.1)), 'NEAR MARKET', 'NO COMPETITOR BASE') AS price_positioning
        FROM
        price_indexing
    )
SELECT *
FROM
final_price_index
QUALIFY row_number() OVER (PARTITION BY item_key, store_key) = 1
ORDER BY
    competitive_set_key ASC,
    is_bidco_supplier DESC
