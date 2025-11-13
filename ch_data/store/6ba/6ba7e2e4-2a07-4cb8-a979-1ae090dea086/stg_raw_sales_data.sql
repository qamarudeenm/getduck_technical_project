ATTACH TABLE _ UUID '075daf4a-ea17-42ba-8da9-3837cbade12f'
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
