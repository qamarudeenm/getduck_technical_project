ATTACH TABLE _ UUID '736360fe-dc3a-49ea-a409-51f5050fc25f'
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
