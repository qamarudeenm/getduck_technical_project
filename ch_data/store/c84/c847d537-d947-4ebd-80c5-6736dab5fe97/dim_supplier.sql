ATTACH TABLE _ UUID '0d6c1e75-b615-419f-b95b-4ef21da78e3c'
(
    `supplier_key` String,
    `supplier_name` String,
    `is_bidco_supplier` Bool,
    `total_distinct_skus_supplied` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
