# Grafana Helm Submodule

This Terraform submodule deploys Grafana to a Kubernetes cluster using the official Helm chart.

## Usage
```hcl
module "grafana" {
  source  = "../modules/grafana"
  kubeconfig = {
    host                   = digitalocean_kubernetes_cluster.this.endpoint
    token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  }
  grafana_chart_version = var.grafana_chart_version
  grafana_helm_values   = var.grafana_helm_values
  enable_grafana        = var.enable_grafana
}
```

## Variables
- `kubeconfig`: Map with Kubernetes API connection details (host, token, cluster_ca_certificate)
- `grafana_chart_version`: Helm chart version
- `grafana_helm_values`: Custom Helm values (YAML as string)
- `enable_grafana`: Whether to enable the release

## Outputs
- `grafana_release_status`: Helm release status
- `grafana_namespace`: Namespace used
- `grafana_service_name`: Service name for the Grafana server 