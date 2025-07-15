# ArgoCD Helm Submodule

This Terraform submodule deploys ArgoCD to a Kubernetes cluster using the official Helm chart.

## Usage
```hcl
module "argocd" {
  source  = "../modules/argocd"
  kubeconfig = {
    host                   = digitalocean_kubernetes_cluster.this.endpoint
    token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  }
  argocd_chart_version = var.argocd_chart_version
  argocd_helm_values   = var.argocd_helm_values
  enable_argocd        = var.enable_argocd
}
```

## Variables
- `kubeconfig`: Map with Kubernetes API connection details (host, token, cluster_ca_certificate)
- `argocd_chart_version`: Helm chart version
- `argocd_helm_values`: Custom Helm values (YAML as string)
- `enable_argocd`: Whether to enable the release

## Outputs
- `argocd_release_status`: Helm release status
- `argocd_namespace`: Namespace used
- `argocd_service_name`: Service name for the ArgoCD server 