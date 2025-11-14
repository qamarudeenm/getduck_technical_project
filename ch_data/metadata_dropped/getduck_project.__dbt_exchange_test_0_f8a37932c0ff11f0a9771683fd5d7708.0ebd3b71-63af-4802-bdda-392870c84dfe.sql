ATTACH TABLE _ UUID '0ebd3b71-63af-4802-bdda-392870c84dfe'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
