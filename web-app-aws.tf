# Deploy a client-side application to AWS.

module "web-app-aws" {
  source = "github.com/wurde/web-app-aws"

  dist_dir      = "./build"
  domain        = "example.com"
  alias_domains = ["www.example.com"]
  default_ttl   = 10
}
