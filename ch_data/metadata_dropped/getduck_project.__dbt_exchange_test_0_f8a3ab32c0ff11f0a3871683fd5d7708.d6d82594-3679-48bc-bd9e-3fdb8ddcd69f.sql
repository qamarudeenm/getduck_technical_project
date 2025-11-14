ATTACH TABLE _ UUID 'd6d82594-3679-48bc-bd9e-3fdb8ddcd69f'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
