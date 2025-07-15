variable "kubeconfig" {
  description = "Kubeconfig for the Kubernetes cluster."
  type        = any
}

variable "prometheus_chart_version" {
  description = "Helm chart version for Prometheus kube-prometheus-stack."
  type        = string
}

variable "prometheus_helm_values" {
  description = "Custom values for the Prometheus Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "enable_prometheus" {
  description = "Whether to install Prometheus via Helm."
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

resource "helm_release" "prometheus" {
  count      = var.enable_prometheus ? 1 : 0
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  namespace  = "monitoring"
  create_namespace = true
  values     = length(trimspace(var.prometheus_helm_values)) > 0 ? [yamldecode(var.prometheus_helm_values)] : []
} 