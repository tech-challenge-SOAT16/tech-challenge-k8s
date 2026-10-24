locals {
  # Prefix delegation: t3.medium passa de 17 para 110 pods por nó.
  addons_before_nodes = {
    "vpc-cni" = jsonencode({
      env = {
        ENABLE_PREFIX_DELEGATION = "true"
        WARM_PREFIX_TARGET       = "1"
      }
    })
    "kube-proxy" = null
  }

  addons_after_nodes = {
    "coredns"            = null
    "metrics-server"     = null
    "aws-ebs-csi-driver" = null
  }
}

data "aws_eks_addon_version" "this" {
  for_each = merge(local.addons_before_nodes, local.addons_after_nodes)

  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.this.version
  most_recent        = true
}

resource "aws_eks_addon" "before_nodes" {
  for_each = local.addons_before_nodes

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = data.aws_eks_addon_version.this[each.key].version
  configuration_values        = each.value
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "after_nodes" {
  for_each = local.addons_after_nodes

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = data.aws_eks_addon_version.this[each.key].version
  configuration_values        = each.value
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]
}
