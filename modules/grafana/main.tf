variable "kubeconfig" {
  description = "Kubeconfig for the Kubernetes cluster."
  type        = any
}

variable "grafana_chart_version" {
  description = "Helm chart version for Grafana."
  type        = string
}

variable "grafana_helm_values" {
  description = "Custom values for the Grafana Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "enable_grafana" {
  description = "Whether to install Grafana via Helm."
  type        = bool
  default     = false
}

provider "helm" {
  kubernetes = {
    host                   = var.kubeconfig["host"]
    token                  = var.kubeconfig["token"]
    cluster_ca_certificate = base64decode(var.kubeconfig["cluster_ca_certificate"])
  }
}

resource "helm_release" "grafana" {
  count      = var.enable_grafana ? 1 : 0
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version
  namespace  = "monitoring"
  create_namespace = true
  values     = length(trimspace(var.grafana_helm_values)) > 0 ? [yamldecode(var.grafana_helm_values)] : []
} 