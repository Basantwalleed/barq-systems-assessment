# RDS subnet group spanning two Availability Zones
resource "aws_db_subnet_group" "postgres" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for the Kubernetes PostgreSQL database"

  subnet_ids = [
    aws_subnet.database_a.id,
    aws_subnet.database_b.id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Private PostgreSQL database
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  backup_retention_period    = 1
  auto_minor_version_upgrade = true
  deletion_protection        = true
  skip_final_snapshot        = false
  final_snapshot_identifier  = var.db_final_snapshot_identifier

  tags = {
    Name = "${var.project_name}-postgres"
    Role = "database"
  }
}
