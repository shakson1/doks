output "argocd_release_status" {
  description = "Status of the ArgoCD Helm release."
  value       = try(helm_release.argocd[0].status, null)
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed."
  value       = "argocd"
}

output "argocd_service_name" {
  description = "Service name for the ArgoCD server."
  value       = "argocd-server"
} 