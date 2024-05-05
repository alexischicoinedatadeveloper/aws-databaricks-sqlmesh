"""Parse sqlmesh external models for trigger in terraform."""

import yaml
import json
import sys

# Open and read the YAML file
with open(sys.argv[1], "r") as file:
    data = yaml.safe_load(file)

# Extract table names and remove backticks
table_names = [entry["name"].replace("`", "") for entry in data]

# Print the result in JSON format
output = json.dumps({"tables": json.dumps(table_names)})
print(output)
