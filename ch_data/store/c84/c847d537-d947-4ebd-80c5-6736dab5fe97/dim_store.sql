ATTACH TABLE _ UUID '532e4310-24e6-4a67-bfbf-ea9fcf00081c'
(
    `store_key` String,
    `store_name` String,
    `total_transactions_recorded` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
