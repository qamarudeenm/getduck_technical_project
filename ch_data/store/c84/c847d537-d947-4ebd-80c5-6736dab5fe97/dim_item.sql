ATTACH TABLE _ UUID 'af644ba5-425b-43ec-95b8-59c617d6852d'
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
