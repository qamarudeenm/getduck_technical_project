ATTACH TABLE _ UUID 'aba1ddd1-fbc0-4b43-91f2-12c73f06873f'
(
    `store_key` String,
    `store_name` String,
    `total_transactions_recorded` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
