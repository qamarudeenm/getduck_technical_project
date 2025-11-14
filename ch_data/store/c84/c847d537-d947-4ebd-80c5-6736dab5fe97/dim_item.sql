ATTACH TABLE _ UUID 'ada092fa-2b71-4ab0-9353-d9f6a00221bd'
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
