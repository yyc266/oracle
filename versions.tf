terraform {
  required_providers {
  huaweicloud = {
    source = "local-registry/huaweicloud/huaweicloud"
    version = "= 1.34.1"
    }
  random = {
    source = "local-registry/hashicorp/random"
    version = "= 3.1.0"
  }
  null = {
    source = "local-registry/hashicorp/null"
    version = "= 3.1.0"
  }
 template = {
    source = "local-registry/hashicorp/template"
    version = "= 2.2.0"
  }
 local = {
    source = "local-registry/hashicorp/local"
    version = "= 2.1.0"
  }
  }
 }

 provider "huaweicloud" {
  region = "cn-north-4"
}
 