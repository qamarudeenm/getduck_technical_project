SELECT
    sale_surrogate_key,
    store_key,
    supplier_key,
    item_key,
    competitive_set_key,
    date_key_int,
    quantity,
    total_sales,
    RRP,
    realised_unit_price,
    discount_depth_percent,
    is_wholesale_bulk,
    is_bidco_sku,
    is_promotional_period_sku

FROM {{ ref('sale_data_cleaned') }}
ORDER BY date_key_int, store_key, item_key