resource "null_resource" "kube-config" {
  depends_on = [aws_eks_node_group.main]

  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${var.env}-eks
kubectl apply -f /opt/vault-token.yaml
EOF
  }
}

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
    command = <<EOF
# Wait until ClusterSecretStore CRD is registered
echo "Waiting for ClusterSecretStore CRD to be ready..."
for i in {1..20}; do
  kubectl get crd clustersecretstores.external-secrets.io >/dev/null 2>&1 && break
  echo "Retrying CRD check ($i)..."
  sleep 5
done

# Wait until API discovery recognizes the version and kind
echo "Waiting for 'external-secrets.io/v1beta1' and kind 'ClusterSecretStore' to be available..."
for i in {1..20}; do
  kubectl api-resources | grep -q "ClusterSecretStore.*external-secrets.io/v1beta1" && break
  echo "Retrying API discovery ($i)..."
  sleep 5
done

# Apply ClusterSecretStore
kubectl apply -f - <<EOK
apiVersion: external-secrets.io/v1beta1
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
          key: "token"
          namespace: kube-system
EOK
EOF
  }
}
