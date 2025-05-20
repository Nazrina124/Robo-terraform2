reosurce "null_resource" "kube-config" {
   provisioner "local-exec" {
    command =<<EOF
aws eks update-kubeconfig --name${var.env}-eks
kubectl apply -f /opt/vault-token.yaml
EOF 
   }

}

#### External secrets
resource "helm_release" "external-secrets" {

  depends_on = [null_resource.kube-config]

  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
  wait       = true
}


