WITH rawdata AS (
SELECT
    store_name,
    item_code,
    item_barcode,
    description,
    category,
    department,
    sub_department,
    section,
    quantity,
    total_sales,
    RRP,
    supplier,
    date_of_sale,
    toDateTime(timestamp(date_of_sale)) AS date_of_sale_casted_for_partition
FROM {{ source('duck_project', 'raw_wkly_data') }}
WHERE store_name != 'Store Name'
)


SELECT
    *
FROM rawdata
