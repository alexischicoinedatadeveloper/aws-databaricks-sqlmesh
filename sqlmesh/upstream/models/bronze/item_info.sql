MODEL (
  name sales.bronze.item_info,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key item_id
  )
);

SELECT
  item_id::INT, /* pk */
  item_name::STRING,
  item_description::STRING,
  price::DOUBLE
FROM postgres_demo_sales_data.sales.item_info