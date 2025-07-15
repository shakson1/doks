output "grafana_release_status" {
  description = "Status of the Grafana Helm release."
  value       = try(helm_release.grafana[0].status, null)
}

output "grafana_namespace" {
  description = "Namespace where Grafana is deployed."
  value       = "monitoring"
}

output "grafana_service_name" {
  description = "Service name for the Grafana server."
  value       = "grafana"
} 