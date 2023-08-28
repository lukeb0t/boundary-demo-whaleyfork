terraform {
  required_version = ">= 1.0"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.69.0"
    }
  }
  cloud {
    organization = "argocorp"
    hostname     = "app.terraform.io"
    workspaces {
      name = "boundary-demo-init"
    }
  }
}

provider "hcp" {}
