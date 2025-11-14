ATTACH TABLE _ UUID '25a3ccbd-42bb-4b4c-a0b8-dc31053574f4'
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
