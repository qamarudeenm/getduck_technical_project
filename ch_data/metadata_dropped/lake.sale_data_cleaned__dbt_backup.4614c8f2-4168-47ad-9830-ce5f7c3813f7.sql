ATTACH TABLE _ UUID '4614c8f2-4168-47ad-9830-ce5f7c3813f7'
(
    `store_key` String,
    `supplier_key` String,
    `item_key` String,
    `sale_surrogate_key` String,
    `competitive_set_key` String,
    `store_name` String,
    `item_code` String,
    `item_barcode` String,
    `description` String,
    `category` String,
    `department` String,
    `sub_department` String,
    `section` String,
    `supplier` String,
    `is_bidco_sku` Bool,
    `is_wholesale_bulk` Bool,
    `brand_name` String,
    `is_promotional_period_sku` Bool,
    `quantity` Nullable(Float64),
    `total_sales` Nullable(Float64),
    `RRP` Nullable(Float64),
    `realised_unit_price` Nullable(Float64),
    `discount_depth_percent` Nullable(Float64),
    `date_of_sale` Date,
    `day_of_week` UInt8,
    `week_start_date` Date,
    `date_key_int` UInt32,
    `date_of_sale_casted_for_partition` Date
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(date_of_sale_casted_for_partition)
ORDER BY date_of_sale_casted_for_partition
SETTINGS allow_nullable_key = true, replicated_deduplication_window = '0', index_granularity = 8192
