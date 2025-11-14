ATTACH TABLE _ UUID 'aaf1b69e-bf1d-4657-932a-16dd0d663f1e'
(
    `supplier_key` String,
    `supplier_name` String,
    `is_bidco_supplier` Bool,
    `total_distinct_skus_supplied` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
