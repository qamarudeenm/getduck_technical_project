ATTACH TABLE _ UUID '0d01174a-6696-4857-b1b0-49540990e370'
(
    `item_key` String,
    `item_code` String,
    `item_barcode` String,
    `item_description` String,
    `category` String,
    `department` String,
    `sub_department` String,
    `section` String,
    `brand_name` String,
    `stores_carrying_item` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
