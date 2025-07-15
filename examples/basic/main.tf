module "doks" {
  source     = "../../"
  do_token   = var.do_token
  region     = "nyc1"
  node_pools = [
    {
      name  = "default-pool"
      size  = "s-2vcpu-4gb"
      count = 3
    }
  ]
}

output "kubeconfig" {
  value     = module.doks.kubeconfig
  sensitive = true
}
output "nginx_ingress_loadbalancer_ip" {
  value = module.doks.nginx_ingress_loadbalancer_ip
} 