ATTACH TABLE _ UUID 'ac0368a2-a609-48df-b55c-d774c6cd1502'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
