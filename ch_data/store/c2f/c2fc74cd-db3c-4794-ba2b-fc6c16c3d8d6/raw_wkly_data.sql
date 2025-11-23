ATTACH TABLE _ UUID '3247839a-be21-411e-a4e1-6e7fd3039821'
(
    `store_name` String,
    `item_code` String,
    `item_barcode` String,
    `description` String,
    `category` String,
    `department` String,
    `sub_department` String,
    `section` String,
    `quantity` String,
    `total_sales` String,
    `RRP` String,
    `supplier` String,
    `date_of_sale` String,
    `date_of_sale_casted_for_partition` DateTime,
    `row_hash` String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(date_of_sale_casted_for_partition)
ORDER BY (date_of_sale_casted_for_partition, item_code)
SETTINGS index_granularity = 8192
