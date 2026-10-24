data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(sort(data.aws_availability_zones.available.names), 0, 2)

  lab_role_arn     = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.lab_role_name}"
  cluster_role_arn = var.create_iam_roles ? aws_iam_role.cluster[0].arn : local.lab_role_arn
  node_role_arn    = var.create_iam_roles ? aws_iam_role.node[0].arn : local.lab_role_arn

  node_subnet_ids = var.enable_nat_gateway ? aws_subnet.private[*].id : aws_subnet.public[*].id
}
