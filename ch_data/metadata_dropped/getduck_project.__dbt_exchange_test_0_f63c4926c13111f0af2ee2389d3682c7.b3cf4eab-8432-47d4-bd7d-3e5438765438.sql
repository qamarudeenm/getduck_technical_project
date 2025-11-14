ATTACH TABLE _ UUID 'b3cf4eab-8432-47d4-bd7d-3e5438765438'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
