variable "kubeconfig" {
  description = "Kubeconfig for the Kubernetes cluster."
  type        = any
}

variable "argocd_chart_version" {
  description = "Helm chart version for ArgoCD."
  type        = string
}

variable "argocd_helm_values" {
  description = "Custom values for the ArgoCD Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "enable_argocd" {
  description = "Whether to install ArgoCD via Helm."
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

resource "helm_release" "argocd" {
  count      = var.enable_argocd ? 1 : 0
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = "argocd"
  create_namespace = true
  values     = length(trimspace(var.argocd_helm_values)) > 0 ? [yamldecode(var.argocd_helm_values)] : []
} 