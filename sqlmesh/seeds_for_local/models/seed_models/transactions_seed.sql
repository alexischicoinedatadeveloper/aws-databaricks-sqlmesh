MODEL (
  name postgres_demo_sales_data.sales.transactions,
  kind SEED (
    path '$root/seeds/transactions.csv'
  )
)