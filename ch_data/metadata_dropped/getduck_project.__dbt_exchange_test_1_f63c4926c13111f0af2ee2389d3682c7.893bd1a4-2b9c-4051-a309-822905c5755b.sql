ATTACH TABLE _ UUID '893bd1a4-2b9c-4051-a309-822905c5755b'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
