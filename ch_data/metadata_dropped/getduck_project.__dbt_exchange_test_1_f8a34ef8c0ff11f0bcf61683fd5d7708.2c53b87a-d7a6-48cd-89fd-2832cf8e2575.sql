ATTACH TABLE _ UUID '2c53b87a-d7a6-48cd-89fd-2832cf8e2575'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
