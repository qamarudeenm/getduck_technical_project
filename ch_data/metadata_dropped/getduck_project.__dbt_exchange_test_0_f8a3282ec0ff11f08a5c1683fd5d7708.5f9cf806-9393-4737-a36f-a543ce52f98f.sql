ATTACH TABLE _ UUID '5f9cf806-9393-4737-a36f-a543ce52f98f'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
