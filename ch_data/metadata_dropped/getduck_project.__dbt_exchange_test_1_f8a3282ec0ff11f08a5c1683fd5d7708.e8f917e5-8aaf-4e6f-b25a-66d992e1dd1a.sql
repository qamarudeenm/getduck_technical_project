ATTACH TABLE _ UUID 'e8f917e5-8aaf-4e6f-b25a-66d992e1dd1a'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
