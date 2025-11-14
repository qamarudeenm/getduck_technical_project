ATTACH TABLE _ UUID 'f99eea4b-cec1-4a7e-bba7-31d7aae7ef7e'
(
    `item_key` String,
    `baseline_daily_units_avg` Nullable(Float64),
    `total_baseline_days` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
