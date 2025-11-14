ATTACH TABLE _ UUID '9a59787a-59a7-4c93-b366-7219b86fa915'
(
    `sale_surrogate_key` String,
    `store_key` String,
    `supplier_key` String,
    `item_key` String,
    `competitive_set_key` String,
    `date_key_int` UInt32,
    `quantity` Nullable(Float64),
    `total_sales` Nullable(Float64),
    `RRP` Nullable(Float64),
    `realised_unit_price` Nullable(Float64),
    `discount_depth_percent` Nullable(Float64),
    `is_wholesale_bulk` Bool,
    `is_bidco_sku` Bool,
    `is_promotional_period_sku` Bool
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
