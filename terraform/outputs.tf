output "vpc_id" {
  description = "ID of the custom Kubernetes VPC"
  value       = aws_vpc.main.id
}

output "control_plane_public_ip" {
  description = "Public IPv4 address of the control-plane node"
  value       = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Private IPv4 address of the control-plane node"
  value       = aws_instance.control_plane.private_ip
}

output "worker_public_ip" {
  description = "Public IPv4 address of the worker node"
  value       = aws_instance.worker.public_ip
}

output "worker_private_ip" {
  description = "Private IPv4 address of the worker node"
  value       = aws_instance.worker.private_ip
}

output "postgres_endpoint" {
  description = "Endpoint for the private PostgreSQL database"
  value       = aws_db_instance.postgres.endpoint
}

output "postgres_port" {
  description = "Port used by PostgreSQL"
  value       = aws_db_instance.postgres.port
}
