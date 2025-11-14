ATTACH TABLE _ UUID 'c22ceacc-d89e-4bc7-a67e-6e2b65c772c6'
(
    `store_key` String,
    `store_name` String,
    `total_transactions_recorded` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
