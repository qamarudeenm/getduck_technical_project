ATTACH TABLE _ UUID 'f8c55134-064f-4e4a-a178-fdaaa089b2e9'
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
    `raw_wkly_data.date_of_sale_casted_for_partition` DateTime,
    `date_of_sale_casted_for_partition` DateTime
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(date_of_sale_casted_for_partition)
ORDER BY date_of_sale_casted_for_partition
SETTINGS allow_nullable_key = true, replicated_deduplication_window = '0', index_granularity = 8192
