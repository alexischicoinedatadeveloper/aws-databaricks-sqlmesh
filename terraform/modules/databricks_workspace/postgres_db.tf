resource "aws_db_instance" "postgres_for_databricks" {
  identifier             = "postgres-for-databricks"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 20 # Enables autoscaling up to 20GB
  username               = databricks_secret.postgres_admin_user.string_value
  password               = databricks_secret.postgres_admin_password.string_value
  db_subnet_group_name   = var.subnet_group_name
  apply_immediately      = true
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = true
  multi_az               = false
}

