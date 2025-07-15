# DigitalOcean Kubernetes Production Module

[![Terraform Registry](https://img.shields.io/badge/terraform--registry-view-blue)](<REGISTRY_URL>)

Deploy a production-ready Kubernetes cluster on DigitalOcean with NGINX Ingress, Prometheus, Grafana, and ArgoCD using Helm.

## Features
- DigitalOcean Kubernetes (DOKS) cluster
- Configurable VPC, region, node pool size/count
- Multiple node pools with autoscaling, labels, taints
- Optional NGINX Ingress Controller (Helm)
- Optional Prometheus + Grafana (Helm)
- Optional ArgoCD (Helm)
- Custom Helm values for each chart
- Advanced Helm configuration: ingress, admin credentials, persistence
- Exposes kubeconfig, cluster endpoint, ingress LB status, Prometheus/Grafana/ArgoCD URLs and credentials

## Usage
See the [basic example](examples/basic/main.tf) for a minimal setup, or the [complete example](examples/complete/main.tf) for a full production configuration.

### Notes on Outputs
- `nginx_ingress_loadbalancer_ip` now outputs the raw Helm release status. To get the actual external IP, check the NGINX ingress service in your cluster after deployment.
- `grafana_admin_password` and `argocd_admin_password` are only output if you explicitly set them in the corresponding Helm values YAML. If you use the chart's default (auto-generated) password, retrieve it from the cluster secrets after deployment.

### Complete Example
The [complete example](examples/complete/main.tf) demonstrates:
- Multiple node pools (with autoscaling, labels, taints)
- NGINX Ingress, Prometheus, Grafana, and ArgoCD all enabled
- Advanced Helm values for:
  - Ingress (with example.com hosts)
  - Persistence (DigitalOcean block storage)
  - Admin credentials (Grafana, ArgoCD)
  - Resource requests/limits for all components

**YAML files used:**
- [nginx-values.yaml](examples/complete/nginx-values.yaml)
- [prometheus-values.yaml](examples/complete/prometheus-values.yaml)
- [grafana-values.yaml](examples/complete/grafana-values.yaml)
- `argocd-values.yaml` (see below for an example)

**Example usage:**
```hcl
module "doks" {
  source     = "<YOUR_GITHUB_OR_REGISTRY_PATH>"
  do_token   = var.do_token
  region     = "nyc1"
  vpc_name   = "prod-vpc"
  cluster_name = "prod-k8s"
  node_pools = [
    {
      name  = "default-pool"
      size  = "s-2vcpu-4gb"
      count = 3
      min_nodes = 2
      max_nodes = 5
      labels = { "role" = "worker" }
      taints = [
        { key = "dedicated", value = "gpu", effect = "NoSchedule" }
      ]
    },
    {
      name  = "gpu-pool"
      size  = "g-2vcpu-8gb"
      count = 1
      min_nodes = 1
      max_nodes = 2
      labels = { "role" = "gpu" }
      taints = [
        { key = "dedicated", value = "gpu", effect = "NoSchedule" }
      ]
    }
  ]
  enable_nginx_ingress = true
  enable_prometheus    = true
  enable_grafana       = true
  enable_argocd        = true
  nginx_ingress_helm_values = file("${path.module}/nginx-values.yaml")
  prometheus_helm_values    = file("${path.module}/prometheus-values.yaml")
  grafana_helm_values       = file("${path.module}/grafana-values.yaml")
  argocd_helm_values        = file("${path.module}/argocd-values.yaml")
}
```

### Example ArgoCD Helm Values
Create a file `argocd-values.yaml`:
```yaml
configs:
  secret:
    argocdServerAdminPassword: "$2a$12$EXAMPLEHASHEDPASSWORD"
server:
  ingress:
    enabled: true
    hosts:
      - argocd.example.com
    annotations:
      kubernetes.io/ingress.class: nginx
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 1Gi
```

## Remote State Recommendations
To safely manage your Terraform state, use a remote backend such as Terraform Cloud, AWS S3, or DigitalOcean Spaces. Example for S3:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "digitalocean-kubernetes/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

- For DigitalOcean Spaces, use the S3-compatible backend with your Spaces credentials.
- For Terraform Cloud, see the [Terraform Cloud documentation](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/configuration).

## Onboarding Tips
- Ensure your DigitalOcean API token has write permissions for Kubernetes, VPC, and Droplets.
- Install the latest Terraform CLI (>= 1.3.0) and configure your credentials.
- Review and customize the example YAML values files for Helm charts in `examples/complete/`.
- Use the provided examples as a starting point and adjust variables for your environment.
- Run `terraform init` before your first apply or after changing providers/modules.

## Retrieving Sensitive Outputs Securely
Some outputs (like kubeconfig, admin passwords) are marked as sensitive. To retrieve them securely:

- Use the Terraform CLI with the `-json` flag for scripting, or the `terraform output` command for human-readable output:

```sh
terraform output kubeconfig
terraform output -json grafana_admin_password
```

- Sensitive outputs will not be shown in the Terraform UI or plan by default. Use the CLI to access them after apply.

## Advanced Helm Chart Configuration

You can override any Helm chart values by passing YAML as a string to the `*_helm_values` variables. See the [complete example YAML files](examples/complete/) for robust production settings.

## Variables
| Name                         | Description                                 | Type   | Default         |
|------------------------------|---------------------------------------------|--------|-----------------|
| do_token                     | DigitalOcean API token                      | string | n/a             |
| region                       | DigitalOcean region                         | string | "nyc1"          |
| vpc_id                       | Existing VPC ID (optional)                  | string | null            |
| vpc_name                     | Name for new VPC                            | string | "k8s-vpc"       |
| cluster_name                 | Cluster name                                | string | "prod-k8s"      |
| k8s_version                  | Kubernetes version                          | string | "1.29.1-do.0"   |
| node_pools                   | List of node pools (see above)              | list   | see above       |
| nginx_ingress_chart_version  | NGINX Ingress Helm chart version            | string | "4.10.0"        |
| prometheus_chart_version     | Prometheus Helm chart version               | string | "56.6.0"        |
| enable_nginx_ingress         | Enable NGINX Ingress                        | bool   | true            |
| enable_prometheus            | Enable Prometheus stack                     | bool   | true            |
| enable_grafana               | Enable standalone Grafana                   | bool   | false           |
| enable_argocd                | Enable ArgoCD                               | bool   | false           |
| nginx_ingress_helm_values    | Custom Helm values for NGINX Ingress        | string | ""              |
| prometheus_helm_values       | Custom Helm values for Prometheus           | string | ""              |
| grafana_helm_values          | Custom Helm values for Grafana              | string | ""              |
| argocd_helm_values           | Custom Helm values for ArgoCD               | string | ""              |

## Outputs
| Name                         | Description                                 |
|------------------------------|---------------------------------------------|
| kubeconfig                   | Kubeconfig for the cluster                  |
| cluster_endpoint             | Kubernetes API endpoint                     |
| nginx_ingress_loadbalancer_ip| Raw Helm release status for NGINX ingress. Check the service in the cluster for the actual IP. |
| prometheus_url               | Prometheus server URL                       |
| grafana_url                  | Grafana server URL                          |
| grafana_admin_password       | Grafana admin password (if set via values)  |
| argocd_url                   | ArgoCD server URL                           |
| argocd_admin_password        | ArgoCD initial admin password (if set via values) |

## Examples
- [Basic example](examples/basic/main.tf): Minimal setup
- [Complete example](examples/complete/main.tf): Full production configuration with all features

--- 