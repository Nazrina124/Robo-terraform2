env = "dev"
bastion_nodes = ["172.31.29.63/32"]
zone_id = "Z03035903COPLEGQ5980F"


vpc = {
    cidr = "10.10.0.0/16"
    public_subnets = ["10.10.0.0/24" , "10.10.1.0/24"]
    web_subnets = ["10.10.2.0/24" , "10.10.3.0/24"]
    app_subnets = ["10.10.4.0/24" , "10.10.5.0/24"]
    db_subnets = ["10.10.6.0/24" , "10.10.7.0/24"]
    availability_zones = ["us-east-1a" , "us-east-1b"]
    default_vpc_id = "vpc-0b3bc4ea0b05389f7"
    default_vpc_rt = "rtb-0c6f868328545ca7b"
    default_vpc_cidr = "172.31.0.0/16"   
}

db = {
    mongo = {
      subnet_ref    = "db"
      instance_type = "t3.small"
      allow_port    = 27017
      allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
    }
    mysql = {
      subnet_ref    = "db"
      instance_type = "t3.small"
      allow_port    = 3306
      allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
    }
    rabbitmq = {
      subnet_ref    = "db"
      instance_type = "t3.small"
      allow_port    = 5672
      allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
    }
    redis = {
      subnet_ref    = "db"
      instance_type = "t3.small"
      allow_port    = 6379
      allow_sg_cidr = ["10.10.4.0/24", "10.10.5.0/24"]
    }
}

eks = {
  eks_version = "1.31"
  node_groups = {
    main-spot = {
      max_size = 3      ### no of nodes max
      min_size = 1      ### no of nodes min
      instance_types = ["t3.medium"]
      capacity_type      = "SPOT"

    }
  }
  add_ons = {
    vpc-cni                = "v1.18.3-eksbuild.2"
    kube-proxy = "v1.30.3-eksbuild.2"
    coredns    = "v1.11.1-eksbuild.11"
  }

eks-iam-access = {
  workstation = {
    principal_arn = "arn:aws:iam::640168456211:role/workstation"
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    kubernetes_groups = []
  }

sso-access = {

    principal_arn =  "arn:aws:iam::640168456211:root"
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    kubernetes_groups = []
  }

}

  }

  
  








