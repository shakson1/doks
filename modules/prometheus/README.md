# Prometheus Helm Submodule

This Terraform submodule deploys the Prometheus kube-prometheus-stack to a Kubernetes cluster using the official Helm chart.

## Usage
```hcl
module "prometheus" {
  source  = "../modules/prometheus"
  kubeconfig = {
    host                   = digitalocean_kubernetes_cluster.this.endpoint
    token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  }
  prometheus_chart_version = var.prometheus_chart_version
  prometheus_helm_values   = var.prometheus_helm_values
  enable_prometheus        = var.enable_prometheus
}
```

## Variables
- `kubeconfig`: Map with Kubernetes API connection details (host, token, cluster_ca_certificate)
- `prometheus_chart_version`: Helm chart version
- `prometheus_helm_values`: Custom Helm values (YAML as string)
- `enable_prometheus`: Whether to enable the release

## Outputs
- `prometheus_release_status`: Helm release status
- `prometheus_namespace`: Namespace used
- `prometheus_service_name`: Service name for the Prometheus server 