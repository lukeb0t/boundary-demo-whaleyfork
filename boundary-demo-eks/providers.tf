terraform {
  required_providers {
    aws = {
      version = "5.14.0"
      source  = "hashicorp/aws"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.69.0"
    }
    kubernetes = {
      version = "2.20.0"
      source  = "hashicorp/kubernetes"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.9"
    }
    okta = {
      source  = "okta/okta"
      version = "4.3.0"
    }
    tfe = {
      version = "0.48.0"
    }
    vault = {
      version = "3.19.0"
    }
      doormat = {
      source  = "doormat.hashicorp.services/hashicorp-security/doormat"
      version = ">= 0.0.3"
    }
  }
  cloud {
    organization = "argocorp"
    hostname     = "app.terraform.io"
    workspaces {
      name = "boundary-demo-eks"
    }
  }
}

provider "doormat" {}

data "doormat_aws_credentials" "creds" {
  provider = doormat
  role_arn = "arn:aws:iam::325038557378:role/boundary-demo-eks"
}


provider "aws" {
  region = var.region
  access_key = data.doormat_aws_credentials.creds.access_key
  secret_key = data.doormat_aws_credentials.creds.secret_key
  token      = data.doormat_aws_credentials.creds.token
}

provider "tfe" {}

provider "boundary" {
  addr                            = data.tfe_outputs.boundary_demo_init.values.boundary_url
  auth_method_id                  = data.tfe_outputs.boundary_demo_init.values.boundary_admin_auth_method
  auth_method_login_name = var.boundary_user
  auth_method_password   = var.boundary_password
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.zts.token
}

provider "okta" {
  org_name = var.okta_org_name
  base_url = var.okta_baseurl
}

provider "vault" {
  address   = data.tfe_outputs.boundary_demo_init.values.vault_pub_url
  token     = data.tfe_outputs.boundary_demo_init.values.vault_token
  namespace = "admin"
}

provider "hcp" {}