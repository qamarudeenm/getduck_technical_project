ATTACH TABLE _ UUID '1a26e122-2cd9-4b38-ad69-354e203808c0'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
