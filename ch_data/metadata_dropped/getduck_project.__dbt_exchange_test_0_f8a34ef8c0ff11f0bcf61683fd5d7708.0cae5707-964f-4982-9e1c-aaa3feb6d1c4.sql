ATTACH TABLE _ UUID '0cae5707-964f-4982-9e1c-aaa3feb6d1c4'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
