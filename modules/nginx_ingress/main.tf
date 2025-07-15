variable "kubeconfig" {
  description = "Kubeconfig for the Kubernetes cluster."
  type        = any
}

variable "nginx_ingress_chart_version" {
  description = "Helm chart version for NGINX Ingress."
  type        = string
}

variable "nginx_ingress_helm_values" {
  description = "Custom values for the NGINX Ingress Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "enable_nginx_ingress" {
  description = "Whether to install NGINX Ingress via Helm."
  type        = bool
  default     = true
}

provider "helm" {
  kubernetes = {
    host                   = var.kubeconfig["host"]
    token                  = var.kubeconfig["token"]
    cluster_ca_certificate = base64decode(var.kubeconfig["cluster_ca_certificate"])
  }
}

resource "helm_release" "nginx_ingress" {
  count      = var.enable_nginx_ingress ? 1 : 0
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_ingress_chart_version
  namespace  = "ingress-nginx"
  create_namespace = true
  values     = length(trimspace(var.nginx_ingress_helm_values)) > 0 ? [yamldecode(var.nginx_ingress_helm_values)] : []
} 