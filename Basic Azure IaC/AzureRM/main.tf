terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.21"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  workload    = "sample"
  environment = "sandbox"
  region      = "westeurope"
  instance    = "1"
  tags = {
    "WorkloadName" = "Sample"
  }
  domain    = "mydomain.onmicrosoft.com"
  linux_sku = "F1"
  pip_sku   = "Standard"
  sql_sku   = "GP_S_Gen5_1" # serverless, pause after 1h idle time

  sql_admin_name = "dbadmin@mydomain.onmicrosoft.com"
}

resource "azurerm_resource_group" "main" {
  name     = lower(format("rg-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location = local.region
  tags     = local.tags
}

resource "azurerm_service_plan" "main" {
  name                = lower(format("asp-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = local.linux_sku
}

resource "azurerm_linux_web_app" "main" {
  name                = lower(format("app-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

resource "azurerm_mssql_server" "main" {
  name                = lower(format("sql-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  version             = "12.0"

  azuread_administrator {
    login_username              = data.azuread_user.main.user_principal_name
    object_id                   = data.azuread_user.main.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true
  }
}

data "azurerm_client_config" "current" {}

data "azuread_user" "main" {
  user_principal_name = local.sql_admin_name
}

resource "azurerm_mssql_database" "main" {
  name                        = lower(format("sqldb-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  server_id                   = azurerm_mssql_server.main.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  license_type                = "LicenseIncluded"
  read_scale                  = false
  sku_name                    = local.sql_sku
  zone_redundant              = false
  storage_account_type        = "Local"
  max_size_gb                 = 1
  min_capacity                = 0.5
  read_replica_count          = 0
  auto_pause_delay_in_minutes = 60

  tags = local.tags
}