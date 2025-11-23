ATTACH TABLE _ UUID 'e2d6d496-a212-45fe-8540-1958dc20bf74'
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
