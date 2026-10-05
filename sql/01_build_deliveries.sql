-- Builds one clean row per delivery with the target and load features.
CREATE OR REPLACE TABLE deliveries AS
WITH base AS (
    SELECT
        ROW_NUMBER() OVER ()                                         AS delivery_id,
        TRY_CAST(market_id AS INTEGER)                               AS market_id,
        TRY_CAST(created_at AS TIMESTAMP)                            AS created_at_utc,
        TRY_CAST(actual_delivery_time AS TIMESTAMP)                  AS delivered_at_utc,
        store_id,
        store_primary_category,
        TRY_CAST(order_protocol AS INTEGER)                          AS order_protocol,
        total_items,
        num_distinct_items,
        subtotal / 100.0                                             AS subtotal_usd,
        min_item_price / 100.0                                       AS min_item_price_usd,
        max_item_price / 100.0                                       AS max_item_price_usd,
        TRY_CAST(total_onshift_dashers AS DOUBLE)                    AS onshift,
        TRY_CAST(total_busy_dashers AS DOUBLE)                       AS busy,
        TRY_CAST(total_outstanding_orders AS DOUBLE)                 AS outstanding,
        estimated_order_place_duration                               AS est_place_sec,
        TRY_CAST(estimated_store_to_consumer_driving_duration AS DOUBLE) AS est_drive_sec
    FROM read_csv_auto('../data/raw/historical_data.csv', nullstr = 'NA')
),
store_cat AS (   -- each store's most common category, used to fill gaps
    SELECT store_id, MODE(store_primary_category) AS filled_category
    FROM base
    WHERE store_primary_category IS NOT NULL
    GROUP BY store_id
)
SELECT
    b.*,
    COALESCE(b.store_primary_category, s.filled_category, 'unknown') AS store_category,
    DATE_DIFF('second', created_at_utc, delivered_at_utc) / 60.0      AS actual_minutes,
    created_at_utc - INTERVAL 8 HOUR                                  AS created_at_pt,
    HOUR(created_at_utc - INTERVAL 8 HOUR)                            AS order_hour_pt,
    DAYOFWEEK(created_at_utc - INTERVAL 8 HOUR)                       AS order_dow_pt,  -- 0 = Sunday
    CASE WHEN onshift > 0 THEN busy / onshift END                     AS busy_ratio,
    CASE WHEN onshift > 0 THEN outstanding / onshift END              AS orders_per_dasher,
    (est_place_sec + est_drive_sec) / 60.0                            AS est_nonprep_minutes
FROM base b
LEFT JOIN store_cat s USING (store_id);