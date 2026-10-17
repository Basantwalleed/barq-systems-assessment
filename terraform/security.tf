# Kubernetes control-plane security group
resource "aws_security_group" "control_plane" {
  name        = "${var.project_name}-control-plane-sg"
  description = "Security group for the Kubernetes control-plane node"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    ignore_changes = [ingress]
  }

  ingress {
    description = "SSH from approved administrator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.approved_ssh_cidr]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-control-plane-sg"
  }
}

# Kubernetes worker security group
resource "aws_security_group" "worker" {
  name        = "${var.project_name}-worker-sg"
  description = "Security group for the Kubernetes worker node"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    ignore_changes = [ingress]
  }

  ingress {
    description = "SSH from approved administrator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.approved_ssh_cidr]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-worker-sg"
  }
}

# PostgreSQL database security group
resource "aws_security_group" "database" {
  name        = "${var.project_name}-database-sg"
  description = "Allow PostgreSQL only from Kubernetes nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-database-sg"
  }
}

# Kubernetes API server: worker nodes to control plane
resource "aws_vpc_security_group_ingress_rule" "api_from_worker" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.worker.id
  description                  = "Kubernetes API server from worker nodes"
  ip_protocol                  = "tcp"
  from_port                    = 6443
  to_port                      = 6443
}

# Kubelet API: control plane to worker

# PostgreSQL: permit access from the Kubernetes nodes
resource "aws_vpc_security_group_ingress_rule" "postgres_from_worker" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.worker.id
  description                  = "PostgreSQL from application worker node"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
# Calico VXLAN traffic: control plane to worker
resource "aws_vpc_security_group_ingress_rule" "calico_vxlan_control_plane" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.worker.id
  description                  = "Calico VXLAN from worker"
  ip_protocol                  = "udp"
  from_port                    = 4789
  to_port                      = 4789
}

# Calico VXLAN traffic: worker to control plane

# Kubernetes API access: administrator to control plane
resource "aws_vpc_security_group_ingress_rule" "api_from_admin" {
  security_group_id = aws_security_group.control_plane.id
  cidr_ipv4         = var.approved_ssh_cidr
  description       = "Kubernetes API from approved administrator IP"
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
}

# PostgreSQL: preserve existing control-plane access
resource "aws_vpc_security_group_ingress_rule" "postgres_from_control_plane" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.control_plane.id
  description                  = "PostgreSQL from control-plane node"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# Preserve existing NodePort access from the approved administrator IP
