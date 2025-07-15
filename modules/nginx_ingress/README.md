# NGINX Ingress Helm Submodule

This Terraform submodule deploys the NGINX Ingress Controller to a Kubernetes cluster using the official Helm chart.

## Usage
```hcl
module "nginx_ingress" {
  source  = "../modules/nginx_ingress"
  kubeconfig = {
    host                   = digitalocean_kubernetes_cluster.this.endpoint
    token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  }
  nginx_ingress_chart_version = var.nginx_ingress_chart_version
  nginx_ingress_helm_values   = var.nginx_ingress_helm_values
  enable_nginx_ingress        = var.enable_nginx_ingress
}
```

## Variables
- `kubeconfig`: Map with Kubernetes API connection details (host, token, cluster_ca_certificate)
- `nginx_ingress_chart_version`: Helm chart version
- `nginx_ingress_helm_values`: Custom Helm values (YAML as string)
- `enable_nginx_ingress`: Whether to enable the release

## Outputs
- `nginx_ingress_release_status`: Helm release status
- `nginx_ingress_namespace`: Namespace used
- `nginx_ingress_service_name`: Service name for the controller 