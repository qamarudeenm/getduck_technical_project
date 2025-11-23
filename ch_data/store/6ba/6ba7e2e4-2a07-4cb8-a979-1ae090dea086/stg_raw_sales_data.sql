ATTACH TABLE _ UUID '1ce24c41-fa84-43b4-87a2-f0eb0b93b7c4'
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
    `date_of_sale_casted_for_partition` DateTime
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(date_of_sale_casted_for_partition)
ORDER BY date_of_sale_casted_for_partition
SETTINGS allow_nullable_key = true, replicated_deduplication_window = '0', index_granularity = 8192
