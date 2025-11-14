ATTACH TABLE _ UUID '2b9c7eb8-e34b-482d-afd2-6a78722ed4ab'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
