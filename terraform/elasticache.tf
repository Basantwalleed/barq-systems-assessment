resource "aws_elasticache_subnet_group" "barq" {
  name = "${var.project_name}-cache-subnets"
  subnet_ids = [
    aws_subnet.database_a.id,
    aws_subnet.database_b.id
  ]

  description = "Private subnets for BARQ managed cache"
}

resource "aws_security_group" "elasticache" {
  name        = "${var.project_name}-elasticache-sg"
  description = "Allow Redis-compatible TLS traffic from the Kubernetes worker"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "TLS cache access from Kubernetes worker"
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = [aws_security_group.worker.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}

resource "aws_elasticache_replication_group" "barq" {
  replication_group_id       = "${var.project_name}-cache"
  description                = "BARQ application managed cache"
  engine                     = "valkey"
  engine_version             = "7.2"
  node_type                  = "cache.t3.micro"
  port                       = 6379
  num_cache_clusters         = 1
  automatic_failover_enabled = false
  multi_az_enabled           = false

  subnet_group_name  = aws_elasticache_subnet_group.barq.name
  security_group_ids = [aws_security_group.elasticache.id]

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  auth_token                 = var.elasticache_auth_token

  apply_immediately = true

  tags = var.common_tags
}

output "elasticache_primary_endpoint_address" {
  description = "Private DNS endpoint for the BARQ managed cache"
  value       = aws_elasticache_replication_group.barq.primary_endpoint_address
}

output "elasticache_port" {
  value = aws_elasticache_replication_group.barq.port
}
