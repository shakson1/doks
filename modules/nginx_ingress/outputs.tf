output "nginx_ingress_release_status" {
  description = "Status of the NGINX Ingress Helm release."
  value       = try(helm_release.nginx_ingress[0].status, null)
}

output "nginx_ingress_namespace" {
  description = "Namespace where NGINX Ingress is deployed."
  value       = "ingress-nginx"
}

output "nginx_ingress_service_name" {
  description = "Service name for the NGINX Ingress controller."
  value       = "ingress-nginx-controller"
} 