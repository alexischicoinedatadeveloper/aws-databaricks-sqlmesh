"""Generate sales data and populate a PostgreSQL database with it."""

# Databricks notebook source
# COMMAND
# MAGIC %md
# MAGIC # Install library for postgres
# Install psycopg2 library to connect to PostgreSQL
# MAGIC %pip install psycopg2-binary

# COMMAND ----------
import datetime
import random
import psycopg2
from databricks.sdk import WorkspaceClient

# COMMAND ----------
dbutils = WorkspaceClient.dbutils

# COMMAND ----------

# MAGIC %md
# MAGIC # Get secrets

# COMMAND ----------

SCOPE_NAME = "postgres_secrets"
demo_data_user, demo_data_password, postgres_host, postgres_port = [
    dbutils.secrets.get(SCOPE_NAME, i_key)
    for i_key in ["demo_data_user", "demo_data_password", "postgres_host", "postgres_port"]
]

# COMMAND ----------

# MAGIC %md
# MAGIC # Connect to postgres

# COMMAND ----------


# Establishing a connection to the database
conn = psycopg2.connect(
    database="demo_data", user=demo_data_user, password=demo_data_password, host=postgres_host, port=postgres_port
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Create schema and tables

# COMMAND ----------

cursor = conn.cursor()

# Creating a 'sales' schema if it doesn't exist
cursor.execute("CREATE SCHEMA IF NOT EXISTS sales;")

# Creating a 'transactions' table within the 'sales' schema if it doesn't exist
cursor.execute(
    """
    CREATE TABLE IF NOT EXISTS sales.transactions (
        transaction_id SERIAL PRIMARY KEY,
        item_id INT NOT NULL,
        quantity INT NOT NULL,
        transaction_date TIMESTAMP NOT NULL,
        total_price DECIMAL(10,2) NOT NULL
    );
"""
)

# Creating an 'item_info' table within the 'sales' schema if it doesn't exist
cursor.execute(
    """
    CREATE TABLE IF NOT EXISTS sales.item_info (
        item_id SERIAL PRIMARY KEY,
        item_name VARCHAR(255) NOT NULL,
        item_description TEXT,
        price DECIMAL(10,2) NOT NULL
    );
"""
)

# Adding a foreign key constraint only if it does not exist
cursor.execute(
    """
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'fk_item'
        ) THEN
            ALTER TABLE sales.transactions
            ADD CONSTRAINT fk_item
            FOREIGN KEY (item_id)
            REFERENCES sales.item_info (item_id);
        END IF;
    END
    $$;
"""
)
conn.commit()
cursor.close()

# COMMAND ----------

# MAGIC %md
# MAGIC # Populate item_info table

# COMMAND ----------

# Check if item_info table is empty
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM sales.item_info;")
result = cursor.fetchone()
is_table_empty = result[0] == 0

# Populate item_info table if it is empty
if is_table_empty:

    items = []
    for i in range(1, 101):
        item_name = f"Item {i}"
        item_description = f"Description {i}"
        price = round(random.uniform(1, 100), 2)
        items.append((item_name, item_description, price))

    cursor.executemany(
        """
        INSERT INTO sales.item_info (item_name, item_description, price)
        VALUES (%s, %s, %s);
    """,
        items,
    )

    conn.commit()

cursor.close()

# COMMAND ----------

# MAGIC %md
# MAGIC # Add random transactions

# COMMAND ----------

# Check the existing item ids
cursor = conn.cursor()
cursor.execute("SELECT item_id FROM sales.item_info;")
existing_item_ids = cursor.fetchall()

# Generate random transactions
transactions = []
for i in range(10_000):
    item_id = random.choice(existing_item_ids)[0]
    quantity = random.randint(1, 10)
    transaction_date = datetime.datetime.now()
    total_price = round(random.uniform(10, 100), 2)
    transactions.append((item_id, quantity, transaction_date, total_price))

# Insert transactions into the transactions table
cursor.executemany(
    """
    INSERT INTO sales.transactions (item_id, quantity, transaction_date, total_price)
    VALUES (%s, %s, %s, %s);
""",
    transactions,
)

conn.commit()
cursor.close()
