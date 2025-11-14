ATTACH TABLE _ UUID 'dfacb9c2-9979-4bca-97e6-515ba9e2453c'
(
    `date_key_int` UInt32,
    `date_actual` Date,
    `year` UInt16,
    `month` UInt8,
    `day_of_month` UInt8,
    `day_of_week_num` UInt8,
    `is_weekend` Bool,
    `week_start_date` Date
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS replicated_deduplication_window = '0', index_granularity = 8192
