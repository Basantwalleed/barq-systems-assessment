# IAM role assumed by the Kubernetes EC2 instances
resource "aws_iam_role" "kubernetes_node" {
  name = "${var.project_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

# Instance profile attached to both Kubernetes nodes
resource "aws_iam_instance_profile" "kubernetes_node" {
  name = "${var.project_name}-node-profile"
  role = aws_iam_role.kubernetes_node.name

  tags = var.common_tags
}
