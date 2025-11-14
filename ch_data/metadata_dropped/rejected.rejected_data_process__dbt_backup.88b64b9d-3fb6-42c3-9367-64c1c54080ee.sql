ATTACH TABLE _ UUID '88b64b9d-3fb6-42c3-9367-64c1c54080ee'
(
    `store_name` String,
    `item_code` String,
    `item_barcode` String,
    `description` String,
    `category` String,
    `department` String,
    `sub_department` String,
    `section` String,
    `quantity` String,
    `total_sales` String,
    `RRP` String,
    `supplier` String,
    `date_of_sale` String,
    `date_of_sale_casted_for_partition` DateTime,
    `rejection_reason` String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(date_of_sale_casted_for_partition)
ORDER BY date_of_sale_casted_for_partition
SETTINGS allow_nullable_key = true, replicated_deduplication_window = '0', index_granularity = 8192
