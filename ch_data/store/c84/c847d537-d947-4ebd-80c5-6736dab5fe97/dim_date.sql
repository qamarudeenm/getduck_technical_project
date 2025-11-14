ATTACH TABLE _ UUID '9e18025e-d89e-464e-9b5f-1a611f1f2efb'
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
