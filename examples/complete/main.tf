module "doks" {
  source     = "../../"
  do_token   = var.do_token
  region     = "nyc1"
  vpc_name   = "prod-vpc"
  cluster_name = "prod-k8s"
  node_pools = [
    {
      name  = "default-pool"
      size  = "s-2vcpu-4gb"
      count = 3
      min_nodes = 2
      max_nodes = 5
      labels = { "role" = "worker" }
      taints = [
        { key = "dedicated", value = "gpu", effect = "NoSchedule" }
      ]
    },
    {
      name  = "gpu-pool"
      size  = "g-2vcpu-8gb"
      count = 1
      min_nodes = 1
      max_nodes = 2
      labels = { "role" = "gpu" }
      taints = [
        { key = "dedicated", value = "gpu", effect = "NoSchedule" }
      ]
    }
  ]
  enable_nginx_ingress = true
  enable_prometheus    = true
  enable_grafana       = true
  enable_argocd        = true
  nginx_ingress_helm_values = file("${path.module}/nginx-values.yaml")
  prometheus_helm_values    = file("${path.module}/prometheus-values.yaml")
  grafana_helm_values       = file("${path.module}/grafana-values.yaml")
  argocd_helm_values        = file("${path.module}/argocd-values.yaml")
}

output "kubeconfig" {
  value     = module.doks.kubeconfig
  sensitive = true
}
output "nginx_ingress_loadbalancer_ip" {
  value = module.doks.nginx_ingress_loadbalancer_ip
}
output "prometheus_url" {
  value = module.doks.prometheus_url
}
output "grafana_url" {
  value = module.doks.grafana_url
}
output "grafana_admin_password" {
  value     = module.doks.grafana_admin_password
  sensitive = true
}
output "argocd_url" {
  value = module.doks.argocd_url
}
output "argocd_admin_password" {
  value     = module.doks.argocd_admin_password
  sensitive = true
} 