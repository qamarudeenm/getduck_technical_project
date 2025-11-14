ATTACH TABLE _ UUID '5c7d3068-3778-41eb-a516-ba2244b050ac'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
