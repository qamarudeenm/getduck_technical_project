ATTACH TABLE _ UUID '9b253044-1fd8-4522-b166-551e5cba4870'
(
    `item_key` String,
    `baseline_daily_units_avg` Nullable(Float64),
    `total_baseline_days` UInt64
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
