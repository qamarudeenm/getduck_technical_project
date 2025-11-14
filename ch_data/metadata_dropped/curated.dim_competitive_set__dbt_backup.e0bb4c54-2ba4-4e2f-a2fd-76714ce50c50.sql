ATTACH TABLE _ UUID 'e0bb4c54-2ba4-4e2f-a2fd-76714ce50c50'
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
