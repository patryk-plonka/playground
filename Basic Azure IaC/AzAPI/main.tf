terraform {
  required_version = ">=1.3.0"
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "~> 1.4"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30"
    }
    # only to get subscription id
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.43.0"
    }
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
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

resource "azapi_resource" "resourceGroup" {
  type = "Microsoft.Resources/resourceGroups@2022-09-01"
  name = lower(format("rg-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location = local.region
  parent_id = lower(format("/subscriptions/%s", data.azurerm_client_config.current.subscription_id))
  tags = local.tags
}

resource "azapi_resource" "appServicePlan" {
  type = "Microsoft.Web/serverfarms@2022-03-01"
  name = lower(format("asp-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location = local.region
  parent_id = azapi_resource.resourceGroup.id
  tags = local.tags
  body = jsonencode({
    sku = {
      name = local.linux_sku
    }
    kind = "Linux"
  })
}

resource "azapi_resource" "linuxWebApp" {
  type = "Microsoft.Web/sites@2022-03-01"
  name = lower(format("app-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location = local.region
  parent_id = azapi_resource.resourceGroup.id
  tags = local.tags
  body = jsonencode({
    properties = {
      serverFarmId = azapi_resource.appServicePlan.id
      siteConfig = {
        appSettings = [
          {
            name = "SOME_KEY"
            value = "some-value"
          }
        ]
        connectionStrings = [
          {
            connectionString = "Server=some-server.mydomain.com;Integrated Security=SSPI"
            name = "Database"
            type = "SQLServer"
          }
        ]
      }
    }
    kind = "app"
  })
}

resource "azapi_resource" "msSqlServer" {
  type = "Microsoft.Sql/servers@2022-05-01-preview"
  name = lower(format("sql-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location = local.region
  parent_id = azapi_resource.resourceGroup.id
  tags = local.tags

  body = jsonencode({
    properties = {
      administrators = {
        administratorType = "ActiveDirectory"
        azureADOnlyAuthentication = true
        login = data.azuread_user.main.user_principal_name
        sid = data.azuread_user.main.object_id
        tenantId = data.azurerm_client_config.current.tenant_id
      }
      version = "12.0"
    }
  })
}

data "azuread_user" "main" {
  user_principal_name = local.sql_admin_name
}


resource "azapi_resource" "msSqlDatabase" {
  type = "Microsoft.Sql/servers/databases@2022-05-01-preview"
  name = lower(format("sqldb-%s-%s-%s-%s", local.workload, local.environment, local.region, local.instance))
  location = local.region
  parent_id = azapi_resource.resourceGroup.id
  tags = local.tags
  body = jsonencode({
    properties = {
      sourceDatabaseId = azapi_resource.msSqlServer.id
      autoPauseDelay = 60
      collation = "SQL_Latin1_General_CP1_CI_AS"
      licenseType = "LicenseIncluded"
      readScale = false
      zoneRedundant = false
      requestedBackupStorageRedundancy = "Local"
      maxSizeBytes = (1024 * 1024 * 1024 * 1)
      minCapacity = "0.5"
    }
    sku = {
      name = local.sql_sku
    }
  })
}