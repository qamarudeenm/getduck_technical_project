ATTACH TABLE _ UUID '6d85864a-6ec5-43f2-b82b-b0b57b861f68'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
