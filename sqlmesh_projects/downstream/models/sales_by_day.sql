MODEL (
  name sales.gold.sales_by_day,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column transaction_date
  )
);

@verify_upstream_models_have_needed_intervals();

SELECT
  transaction_date::DATE,
  item_name,
  item_description,
  SUM(total_price) AS daily_sales
FROM sales.bronze.transactions
INNER JOIN sales.bronze.item_info
  USING (item_id)
GROUP BY ALL