WITH sales_context AS (
    SELECT
        f.item_key AS item_key,
        f.store_key AS store_key,
        f.realised_unit_price AS realised_unit_price,
        f.RRP AS RRP,
        f.discount_depth_percent AS discount_depth_percent,
        d_c.competitive_set_key AS competitive_set_key,
        d_c.sub_department AS sub_department,
        d_c.section AS section,
        d_c.store_name AS store_name,        
        d_i.brand_name AS brand_name,
        d_s.is_bidco_supplier AS is_bidco_supplier
        
    FROM {{ ref('fact_sales_transaction') }} f
    INNER JOIN {{ ref('dim_competitive_set') }} d_c
        ON f.competitive_set_key = d_c.competitive_set_key
    INNER JOIN {{ ref('dim_supplier') }} d_s
        ON f.supplier_key = d_s.supplier_key
    INNER JOIN {{ ref('dim_item') }} d_i
        ON f.item_key = d_i.item_key
),

price_indexing AS (
    -- Use Window Function partitioned by the Competitive Set Key 
    --    to calculate the Peer Average Price (excluding the current supplier)
    SELECT
        *,
        
        -- Calculate Peer Price: Average Realised Price of all COMPETITORS
        -- Only average the prices for suppliers where is_bidco_supplier = FALSE
        ROUND(
            AVG(CASE WHEN is_bidco_supplier = FALSE THEN realised_unit_price ELSE NULL END)
            OVER (PARTITION BY competitive_set_key), 
            2
        ) AS peer_avg_unit_price
        
    FROM sales_context
),

final_price_index AS (
    SELECT
        item_key,
        store_key,
        competitive_set_key,
        store_name,
        sub_department,
        section,
        brand_name,
        is_bidco_supplier,
        -- Metrics
        realised_unit_price,
        RRP,
        discount_depth_percent,
        peer_avg_unit_price,

        -- KPI - Peer Price Index (PPI)
        -- Formula: (Own Price / Peer Avg Price) - 1.0. Positive means higher, Negative means lower.
        CASE 
            WHEN peer_avg_unit_price IS NULL OR peer_avg_unit_price = 0 THEN NULL
            ELSE ROUND( (realised_unit_price / peer_avg_unit_price), 4)
        END AS peer_price_index,
        
        -- KPI - Price Positioning (Categorical answer to "is price too high/low?")
        CASE
            -- Price is at Premium (> 10% above peer)
            WHEN realised_unit_price > (peer_avg_unit_price * 1.10) THEN 'PREMIUM (10%+ High)'
            -- Price is at Discount (> 10% below peer)
            WHEN realised_unit_price < (peer_avg_unit_price * 0.90) THEN 'DISCOUNT (10%+ Low)'
            -- Price is near market (within +/- 10% of peer)
            WHEN realised_unit_price BETWEEN (peer_avg_unit_price * 0.90) AND (peer_avg_unit_price * 1.10) THEN 'NEAR MARKET'
            ELSE 'NO COMPETITOR BASE' -- When peer_avg_unit_price is NULL/0
        END AS price_positioning
        
    FROM price_indexing
)

SELECT * 
FROM final_price_index
QUALIFY ROW_NUMBER() OVER (PARTITION BY item_key, store_key) = 1
ORDER BY competitive_set_key, is_bidco_supplier DESC
