ATTACH TABLE _ UUID '81cf86d5-33b6-4dd1-8046-8cca5dff0aa6'
(
    `supplier_key` String,
    `supplier_name` String,
    `is_bidco_supplier` Bool,
    `total_distinct_skus_supplied` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
