MODEL (
  name sales.bronze.transactions,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key transaction_id
  )
);

SELECT
  transaction_id::INT, /* pk */
  item_id::INT, /* fk */
  quantity::INT,
  transaction_date::STRING,
  total_price::DOUBLE
FROM postgres_demo_sales_data.sales.transactions