variable "do_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for the cluster."
  type        = string
  default     = "nyc1"
  validation {
    condition = contains([
      "nyc1", "nyc2", "nyc3", "ams3", "sfo2", "sfo3", "sgp1", "lon1", "fra1", "tor1", "blr1", "syd1", "atl1"
    ], var.region)
    error_message = "Region must be one of: nyc1, nyc2, nyc3, ams3, sfo2, sfo3, sgp1, lon1, fra1, tor1, blr1, syd1, atl1."
  }
}

variable "vpc_id" {
  description = "Existing VPC ID to use. If not set, a new VPC will be created."
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "Name for the VPC if created."
  type        = string
  default     = "k8s-vpc"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster."
  type        = string
  default     = "prod-k8s"
}

variable "k8s_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.29.1-do.0"
}

variable "node_pools" {
  description = <<EOT
List of node pools to create. Each object supports:
- name: (string) Name of the node pool
- size: (string) Droplet size
- count: (number) Initial node count
- min_nodes: (number, optional) Minimum nodes for auto-scaling
- max_nodes: (number, optional) Maximum nodes for auto-scaling
- labels: (map, optional) Node labels
- taints: (list(object), optional) Node taints (key, value, effect)
EOT
  type = list(object({
    name      = string
    size      = string
    count     = number
    min_nodes = optional(number)
    max_nodes = optional(number)
    labels    = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))
  default = [
    {
      name  = "default-pool"
      size  = "s-2vcpu-4gb"
      count = 3
    }
  ]
  validation {
    condition = alltrue([
      for np in var.node_pools : contains([
        "s-1vcpu-512mb-10gb", "s-1vcpu-1gb", "s-2vcpu-2gb", "s-2vcpu-4gb", "s-4vcpu-8gb", "s-8vcpu-16gb",
        "c-2", "c-4", "c-8", "c-16", "c-32", "c-48",
        "g-2vcpu-8gb", "g-4vcpu-16gb", "g-8vcpu-32gb", "g-16vcpu-64gb", "g-32vcpu-128gb", "g-40vcpu-160gb",
        "m-2vcpu-16gb", "m-4vcpu-32gb", "m-8vcpu-64gb", "m-16vcpu-128gb", "m-24vcpu-192gb", "m-32vcpu-256gb",
        "so-2vcpu-16gb", "so-4vcpu-32gb", "so-8vcpu-64gb", "so-16vcpu-128gb", "so-24vcpu-192gb", "so-32vcpu-256gb"
      ], np.size)
    ])
    error_message = "Each node pool size must be a valid DigitalOcean Droplet size slug. See https://www.digitalocean.com/pricing/droplets for options."
  }
  validation {
    condition = alltrue([
      for np in var.node_pools : np.count >= 1
    ])
    error_message = "Each node pool must have at least 1 node."
  }
}

variable "nginx_ingress_chart_version" {
  description = "Helm chart version for NGINX Ingress."
  type        = string
  default     = "4.10.0"
}

variable "prometheus_chart_version" {
  description = "Helm chart version for Prometheus kube-prometheus-stack."
  type        = string
  default     = "56.6.0"
}

variable "enable_nginx_ingress" {
  description = "Whether to install NGINX Ingress via Helm."
  type        = bool
  default     = true
}

variable "enable_prometheus" {
  description = "Whether to install Prometheus via Helm."
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Whether to install Grafana via Helm (separate from Prometheus stack)."
  type        = bool
  default     = false
}

variable "nginx_ingress_helm_values" {
  description = "Custom values for the NGINX Ingress Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "prometheus_helm_values" {
  description = "Custom values for the Prometheus Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "grafana_helm_values" {
  description = "Custom values for the Grafana Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "enable_argocd" {
  description = "Whether to install ArgoCD via Helm."
  type        = bool
  default     = false
}

variable "argocd_helm_values" {
  description = "Custom values for the ArgoCD Helm chart (YAML as string)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to all resources (DigitalOcean and Kubernetes labels where possible). Common keys: environment, project, owner."
  type        = map(string)
  default = {
    environment = "dev"
    project     = "doks-cluster"
    owner       = "team"
  }
}

variable "grafana_chart_version" {
  description = "Helm chart version for Grafana."
  type        = string
  default     = "7.3.9"
}

variable "argocd_chart_version" {
  description = "Helm chart version for ArgoCD."
  type        = string
  default     = "6.7.12"
} 