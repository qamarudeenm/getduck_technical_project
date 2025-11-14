ATTACH TABLE _ UUID '634ce7b3-cbb6-4e7b-b2d9-c315f0e735fd'
(
    `test` String
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
