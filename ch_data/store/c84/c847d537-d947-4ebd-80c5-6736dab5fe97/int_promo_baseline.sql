ATTACH TABLE _ UUID 'c1cb1113-a28a-47a3-bf93-e12dfdd5d04e'
(
    `item_key` String,
    `baseline_daily_units_avg` Nullable(Float64),
    `total_baseline_days` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
