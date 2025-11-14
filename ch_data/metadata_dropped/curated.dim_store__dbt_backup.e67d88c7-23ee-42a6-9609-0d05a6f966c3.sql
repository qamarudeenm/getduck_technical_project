ATTACH TABLE _ UUID 'e67d88c7-23ee-42a6-9609-0d05a6f966c3'
(
    `store_key` String,
    `store_name` String,
    `total_transactions_recorded` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
