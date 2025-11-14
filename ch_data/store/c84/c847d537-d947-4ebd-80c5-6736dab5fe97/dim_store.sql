ATTACH TABLE _ UUID '74fb99a2-9618-4d07-a37b-9106be2418c7'
(
    `store_key` String,
    `store_name` String,
    `total_transactions_recorded` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
