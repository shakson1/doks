output "kubeconfig" {
  description = "Kubeconfig for the cluster."
  value = digitalocean_kubernetes_cluster.this.kube_config[0].raw_config
  sensitive = true
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value = digitalocean_kubernetes_cluster.this.endpoint
}

output "nginx_ingress_loadbalancer_ip" {
  description = "The raw status of the NGINX ingress Helm release. Check the service in the cluster for the actual IP."
  value = try(helm_release.nginx_ingress[0].status, null)
}

output "prometheus_url" {
  description = "Prometheus server URL (if enabled)."
  value = var.enable_prometheus ? "http://prometheus-server.monitoring.svc.cluster.local" : null
}

output "grafana_url" {
  description = "Grafana server URL (if enabled)."
  value = var.enable_grafana ? "http://grafana.monitoring.svc.cluster.local" : (var.enable_prometheus ? "http://prometheus-grafana.monitoring.svc.cluster.local" : null)
}

output "grafana_admin_password" {
  description = "Grafana admin password (if set via values)."
  value = var.enable_grafana && length(trimspace(var.grafana_helm_values)) > 0 ? (try(yamldecode(var.grafana_helm_values).adminPassword, null)) : null
  sensitive = true
}

output "argocd_url" {
  description = "ArgoCD server URL (if enabled)."
  value = var.enable_argocd ? "http://argocd-server.argocd.svc.cluster.local" : null
}

output "argocd_admin_password" {
  description = "ArgoCD initial admin password (if set via values)."
  value = var.enable_argocd && length(trimspace(var.argocd_helm_values)) > 0 ? (try(yamldecode(var.argocd_helm_values).configs.secret.argocdServerAdminPassword, null)) : null
  sensitive = true
} 