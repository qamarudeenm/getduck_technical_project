ATTACH TABLE _ UUID '64385094-f1d9-4ad4-a03a-58482d378a93'
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
