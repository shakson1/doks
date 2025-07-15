output "prometheus_release_status" {
  description = "Status of the Prometheus Helm release."
  value       = try(helm_release.prometheus[0].status, null)
}

output "prometheus_namespace" {
  description = "Namespace where Prometheus is deployed."
  value       = "monitoring"
}

output "prometheus_service_name" {
  description = "Service name for the Prometheus server."
  value       = "prometheus-server"
} 