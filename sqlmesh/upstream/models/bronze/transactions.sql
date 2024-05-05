MODEL (
  name sales.bronze.transactions,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key transaction_id
  )
);

WITH data AS (
  SELECT
    transaction_id::INT, /* pk */
    item_id::INT, /* fk */
    quantity::INT,
    transaction_date::STRING,
    total_price::DOUBLE,
    @start_ts::TIMESTAMP AS start_ts,
    @end_ts::TIMESTAMP AS end_ts
  FROM postgres_demo_sales_data.sales.transactions
)
SELECT
  *
FROM data
UNION ALL
SELECT
  NULL::INT,
  NULL::INT,
  NULL::INT,
  NULL::STRING,
  NULL::DOUBLE,
  @start_ts::TIMESTAMP AS start_ts,
  @end_ts::TIMESTAMP AS end_ts
WHERE
  (
    SELECT
      COUNT(1)
    FROM data
  ) = 0