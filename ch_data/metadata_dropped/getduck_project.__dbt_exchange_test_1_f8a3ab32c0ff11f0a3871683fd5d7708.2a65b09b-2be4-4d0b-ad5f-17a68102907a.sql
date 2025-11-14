ATTACH TABLE _ UUID '2a65b09b-2be4-4d0b-ad5f-17a68102907a'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
