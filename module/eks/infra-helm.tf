resource "null_resource" "kube-config" {
  depends_on = [aws_eks_node_group.main]

  provisioner "local-exec" {
    command =<<EOF
aws eks update-kubeconfig --name ${var.env}-eks
kubectl apply -f /opt/vault-token.yaml
EOF
  }
}

## External Secrets
resource "helm_release" "external-secrets" {

  depends_on = [null_resource.kube-config]

  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
  wait       = true
}

resource "null_resource" "external-secrets-store" {
  depends_on = [helm_release.external-secrets]

  provisioner "local-exec" {
    command =<<EOF
kubectl apply -f - <<EOK
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault.naifah.online:8200/"
      path: "roboshop-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "Token"
          namespace: kube-system
EOK
EOF
  }
}


#### Install server for HPA

resource "null_resource" "metric-server" {
  depends_on = [null_resource.kube-config]

  provisioner "local-exec" {
    command =<<EOF
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
EOF
  }
}