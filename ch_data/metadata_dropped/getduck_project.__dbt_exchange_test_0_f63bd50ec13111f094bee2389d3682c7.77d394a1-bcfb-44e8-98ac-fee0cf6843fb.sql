ATTACH TABLE _ UUID '77d394a1-bcfb-44e8-98ac-fee0cf6843fb'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
