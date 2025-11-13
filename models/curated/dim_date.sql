SELECT
    toYYYYMMDD(date_of_sale) AS date_key_int,
    date_of_sale AS date_actual,
    toYear(date_of_sale) AS year,
    toMonth(date_of_sale) AS month,
    toDayOfMonth(date_of_sale) AS day_of_month,
    toDayOfWeek(date_of_sale) AS day_of_week_num, -- 1=Monday, 7=Sunday
    CASE 
        WHEN toDayOfWeek(date_of_sale) IN (6, 7) THEN TRUE  -- Saturday (6) or Sunday (7)
        ELSE FALSE 
    END AS is_weekend,
    toStartOfWeek(date_of_sale) AS week_start_date

FROM (
    SELECT DISTINCT date_of_sale
    FROM {{ ref('sale_data_cleaned') }}
)
ORDER BY 1