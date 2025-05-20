resource "aws_eks_cluster" "main" {
  name = "${var.env}-eks"
  role_arn = aws_iam_role.eks-cluster.arn
  version =  var.eks_version
  
  vpc_config {
    subnet_ids = var.subnet_ids
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"  
    bootstrap_cluster_creator_admin_permissions = true
  }

}

 resource "aws_eks_node_group" "main" {
    for_each      =     var.node_groups                   ####### for_each is loop
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = var.subnet_ids
  instance_types   = each.value["instance_types"]
  capacity_type       = each.value["capacity_type"]

  scaling_config {                              ####### because this is loop we will input data in main.tf.vars
    desired_size = each.value["min_size"]   
    max_size     = each.value["max_size"] 
    min_size     = each.value["min_size"] 
  }

 }

resource "aws_eks_addon" "addons" {
  for_each    =  var.add_ons
  cluster_name = aws_eks_cluster.main.name
  addon_name    = each.key
  addon_version  = each.value
  resolve_conflicts_on_update = "OVERWRITE"
}


module "eks-iam-access" {
   source = "./eks-iam-access"
   for_each = var.eks-iam-access
   
   cluster_name  = aws_eks_cluster.main.name
   principal_arn = each.value["principal_arn"]
   policy_arn    = each.value["policy_arn"]
   kubernetes_groups = each.value["kubernetes_groups"]

}