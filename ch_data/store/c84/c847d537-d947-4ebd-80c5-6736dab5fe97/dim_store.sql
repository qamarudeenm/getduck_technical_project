ATTACH TABLE _ UUID '9d01be2e-e6ec-46d1-99fa-6d5d19efe3e9'
(
    `store_key` String,
    `store_name` String,
    `total_transactions_recorded` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
