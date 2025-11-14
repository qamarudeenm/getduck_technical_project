ATTACH TABLE _ UUID 'dfd89381-05fd-435b-b57b-d3e4567e4684'
(
    `supplier_key` String,
    `supplier_name` String,
    `is_bidco_supplier` Bool,
    `total_distinct_skus_supplied` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
