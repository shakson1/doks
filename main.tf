// DigitalOcean provider and required providers
provider "digitalocean" {
  token = var.do_token
}

// Optionally create a VPC if vpc_id is not provided
resource "digitalocean_vpc" "this" {
  count = var.vpc_id == null ? 1 : 0
  name   = var.vpc_name
  region = var.region
}

// Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "this" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version
  vpc_uuid = var.vpc_id != null ? var.vpc_id : digitalocean_vpc.this[0].id

  dynamic "node_pool" {
    for_each = var.node_pools
    content {
      name       = node_pool.value.name
      size       = node_pool.value.size
      node_count = node_pool.value.count
      auto_scale = contains(keys(node_pool.value), "min_nodes") && contains(keys(node_pool.value), "max_nodes")
      min_nodes  = try(node_pool.value.min_nodes, null)
      max_nodes  = try(node_pool.value.max_nodes, null)
      labels     = try(node_pool.value.labels, null)

      dynamic "taint" {
        for_each = try(node_pool.value.taints, [])
        content {
          key    = taint.value.key
          value  = taint.value.value
          effect = taint.value.effect
        }
      }
    }
  }
}

// Helm provider
provider "helm" {
  kubernetes = {
    host                   = digitalocean_kubernetes_cluster.this.endpoint
    token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}

// NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  count      = var.enable_nginx_ingress ? 1 : 0
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_ingress_chart_version
  namespace  = "ingress-nginx"
  create_namespace = true
  values     = length(trimspace(var.nginx_ingress_helm_values)) > 0 ? [yamldecode(var.nginx_ingress_helm_values)] : []
  depends_on = [digitalocean_kubernetes_cluster.this]
}

// Prometheus
resource "helm_release" "prometheus" {
  count      = var.enable_prometheus ? 1 : 0
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  namespace  = "monitoring"
  create_namespace = true
  values     = length(trimspace(var.prometheus_helm_values)) > 0 ? [yamldecode(var.prometheus_helm_values)] : []
  depends_on = [digitalocean_kubernetes_cluster.this]
}

// Grafana (included in kube-prometheus-stack, but can be separated if needed) 
resource "helm_release" "grafana" {
  count      = var.enable_grafana ? 1 : 0
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.9"
  namespace  = "monitoring"
  create_namespace = true
  values     = length(trimspace(var.grafana_helm_values)) > 0 ? [yamldecode(var.grafana_helm_values)] : []
  depends_on = [digitalocean_kubernetes_cluster.this]
} 

resource "helm_release" "argocd" {
  count      = var.enable_argocd ? 1 : 0
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12"
  namespace  = "argocd"
  create_namespace = true
  values     = length(trimspace(var.argocd_helm_values)) > 0 ? [yamldecode(var.argocd_helm_values)] : []
  depends_on = [digitalocean_kubernetes_cluster.this]
} 