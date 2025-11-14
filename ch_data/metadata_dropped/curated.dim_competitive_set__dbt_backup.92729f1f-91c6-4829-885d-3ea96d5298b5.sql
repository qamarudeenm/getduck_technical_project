ATTACH TABLE _ UUID '92729f1f-91c6-4829-885d-3ea96d5298b5'
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
