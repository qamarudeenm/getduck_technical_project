ATTACH TABLE _ UUID '5a13746d-fa0f-4758-b00e-d5e253e8e873'
(
    `supplier_key` String,
    `supplier_name` String,
    `is_bidco_supplier` Bool,
    `total_distinct_skus_supplied` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
