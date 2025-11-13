ATTACH TABLE _ UUID 'af4d66a5-47f3-4c7d-90ae-acc9868668a7'
(
    `item_key` String,
    `baseline_daily_units_avg` Nullable(Float64),
    `total_baseline_days` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
