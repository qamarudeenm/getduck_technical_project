ATTACH TABLE _ UUID '7bebcf10-98c6-49ff-ba13-1f9740fbe1b2'
(
    `competitive_set_key` String,
    `sub_department` String,
    `section` String,
    `store_name` String,
    `total_suppliers_in_set` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
