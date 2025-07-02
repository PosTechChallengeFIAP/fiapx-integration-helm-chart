resource "aws_eks_cluster" "main" {
  name     = "academy-eks-cluster"
  role_arn = var.lab_role_arn

  version = "1.29"

  vpc_config {
    subnet_ids =  module.vpc.private_subnets
    endpoint_public_access = true
  }

  depends_on = [module.vpc]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "academy-eks-nodes"
  node_role_arn = var.lab_role_arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}