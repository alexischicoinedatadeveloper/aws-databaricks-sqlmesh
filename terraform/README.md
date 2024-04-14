# Terraform
We're using terraform for infrastructure as code.
However, a few things had to be setup manually to get started.
- An admin IAM user was created in AWS along with an access key.
- A service principal was created in Databricks.
- An S3 bucket was created to store the terraform state.
- The secrets for the users and account names were stored in Github secrets.

# Databricks Terraform
We'll use examples from Databricks' repository to get started.
https://github.com/databricks/terraform-databricks-examples
We'll also refer to [previous work I did](https://www.linkedin.com/posts/alexis-chicoine-2babb464_databricks-terraform-unitycatalog-activity-7174891423761084417-Xz93?utm_source=share&utm_medium=member_desktop).

Ended up following this guide which worked:
https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-workspace

In vpc.tf we can set enable_nat_gateway = false to delete the gateway and save costs.
It's better to do this once clusters are shut down otherwise strange things will happen.
The next time we want to use Databricks we set it back to true and run terraform.