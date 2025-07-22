variable "kube_config" {
  description = "Kubernetes kube_config object (from digitalocean_kubernetes_cluster.this.kube_config[0])."
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
    host                   = var.kube_config["host"]
    token                  = var.kube_config["token"]
    cluster_ca_certificate = base64decode(var.kube_config["cluster_ca_certificate"])
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