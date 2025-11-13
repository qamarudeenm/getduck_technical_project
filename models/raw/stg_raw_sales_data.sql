WITH rawdata AS (
SELECT
    *,
    toDateTime(timestamp(date_of_sale)) AS date_of_sale_casted_for_partition
FROM {{ source('duck_project', 'raw_wkly_data') }}
where store_name != 'Store Name'
)


SELECT
    *
FROM rawdata
