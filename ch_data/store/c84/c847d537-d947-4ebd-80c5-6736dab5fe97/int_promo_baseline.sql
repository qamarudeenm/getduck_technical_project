ATTACH TABLE _ UUID 'e0638d8e-ce64-4347-9d10-98547ddca755'
(
    `item_key` String,
    `baseline_daily_units_avg` Nullable(Float64),
    `total_baseline_days` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
