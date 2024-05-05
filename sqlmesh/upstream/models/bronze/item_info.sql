MODEL (
  name sales.bronze.item_info,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key item_id
  )
);

WITH data AS (
  SELECT
    item_id::INT, /* pk */
    item_name::STRING,
    price::DOUBLE,
    @start_ts::TIMESTAMP AS start_ts,
    @end_ts::TIMESTAMP AS end_ts
  FROM postgres_demo_sales_data.sales.item_info
)
SELECT
  *
FROM data
UNION ALL
SELECT
  NULL::INT,
  NULL::STRING,
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