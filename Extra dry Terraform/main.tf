terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.21"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = upper(format("rg-%s-%s-%s-%s", var.general.workload, var.general.environment, var.general.region, var.general.instance))
  location = var.general.region
  tags     = var.general.tags
}

