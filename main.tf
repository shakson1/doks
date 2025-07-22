// DigitalOcean provider and required providers
provider "digitalocean" {
  token = var.do_token
}

// Optionally create a VPC if vpc_id is not provided
resource "digitalocean_vpc" "this" {
  count  = var.vpc_id == null ? 1 : 0
  name   = var.vpc_name
  region = var.region
}

// Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "this" {
  name     = var.cluster_name
  region   = var.region
  version  = var.k8s_version
  vpc_uuid = var.vpc_id != null ? var.vpc_id : digitalocean_vpc.this[0].id
  tags     = values(var.tags)

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

# Submodule: NGINX Ingress
module "nginx_ingress" {
  source                      = "./modules/nginx_ingress"
  kube_config                 = digitalocean_kubernetes_cluster.this.kube_config[0]
  nginx_ingress_chart_version = var.nginx_ingress_chart_version
  nginx_ingress_helm_values   = var.nginx_ingress_helm_values
  enable_nginx_ingress        = var.enable_nginx_ingress
}

# Submodule: Prometheus
module "prometheus" {
  source                   = "./modules/prometheus"
  kube_config              = digitalocean_kubernetes_cluster.this.kube_config[0]
  prometheus_chart_version = var.prometheus_chart_version
  prometheus_helm_values   = var.prometheus_helm_values
  enable_prometheus        = var.enable_prometheus
}

# Submodule: Grafana
module "grafana" {
  source                = "./modules/grafana"
  kube_config           = digitalocean_kubernetes_cluster.this.kube_config[0]
  grafana_chart_version = var.grafana_chart_version
  grafana_helm_values   = var.grafana_helm_values
  enable_grafana        = var.enable_grafana
}

# Submodule: ArgoCD
module "argocd" {
  source               = "./modules/argocd"
  kube_config          = digitalocean_kubernetes_cluster.this.kube_config[0]
  argocd_chart_version = var.argocd_chart_version
  argocd_helm_values   = var.argocd_helm_values
  enable_argocd        = var.enable_argocd
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.this.endpoint
  token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = module.nginx_ingress.nginx_ingress_service_name
    namespace = module.nginx_ingress.nginx_ingress_namespace
  }
  depends_on = [module.nginx_ingress]
} 