terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.92.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Re-use the existing resource group
resource "azurerm_resource_group" "front_end_rg" {
  name     = "rg-frontend-sand-ne-001"
  location = "northeurope"
}

# Define the storage account for Linux-based function app
resource "azurerm_storage_account" "front_end_storage_account" {
  name                     = "stgsandfrontendne2192024"
  location                 = azurerm_resource_group.front_end_rg.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  resource_group_name      = azurerm_resource_group.front_end_rg.name

  static_website {
    index_document = "index.html"
  }
}

# Define storage account for Windows-based function app
resource "azurerm_storage_account" "products_service_fa" {
  name                     = "stgsandproductsfane002"
  location                 = azurerm_resource_group.front_end_rg.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  resource_group_name      = azurerm_resource_group.front_end_rg.name
}

# Create an App Service Plan for Linux-based Function App
resource "azurerm_service_plan" "function_app_plan" {
  name                = "function-app-plan"
  location            = azurerm_resource_group.front_end_rg.location
  resource_group_name = azurerm_resource_group.front_end_rg.name
  os_type             = "Linux"
  sku_name            = "Y1"   # "Y1" for Consumption (Dynamic) plan
}

# Create an App Service Plan for Windows-based Function App
resource "azurerm_service_plan" "product_service_plan" {
  name                = "asp-product-service-sand-ne-001"
  location            = azurerm_resource_group.front_end_rg.location
  resource_group_name = azurerm_resource_group.front_end_rg.name
  os_type             = "Windows"
  sku_name            = "Y1"   # "Y1" for Consumption (Dynamic) plan
}


resource "azurerm_linux_function_app" "products_function_app" {
  name                       = "fa-products-svc-06-10-2024"
  location                   = azurerm_resource_group.front_end_rg.location
  resource_group_name         = azurerm_resource_group.front_end_rg.name
  storage_account_name        = azurerm_storage_account.front_end_storage_account.name
  storage_account_access_key  = azurerm_storage_account.front_end_storage_account.primary_access_key
  service_plan_id             = azurerm_service_plan.function_app_plan.id

  site_config {
    # Minimum block requirement
    application_stack {
      node_version = "18"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "node"
  }
}


# Define the Windows-based Function App
resource "azurerm_windows_function_app" "products_service" {
  name                = "fa-products-svc-07-10-2024"
  location            = azurerm_resource_group.front_end_rg.location
  resource_group_name = azurerm_resource_group.front_end_rg.name
  service_plan_id     = azurerm_service_plan.product_service_plan.id

  storage_account_name       = azurerm_storage_account.products_service_fa.name
  storage_account_access_key = azurerm_storage_account.products_service_fa.primary_access_key

  functions_extension_version = "~4"
  builtin_logging_enabled     = false

  site_config {
    always_on = false
    use_32_bit_worker = true
    application_insights_key = azurerm_application_insights.products_service_fa.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.products_service_fa.connection_string
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.products_service_fa.primary_connection_string
    WEBSITE_CONTENTSHARE                     = azurerm_storage_share.products_service_fa.name
  }
}


# Define Application Insights for the Windows-based Function App
resource "azurerm_application_insights" "products_service_fa" {
  name                = "appins-fa-products-service-sand-ne-001"
  location            = azurerm_resource_group.front_end_rg.location
  application_type    = "web"
  resource_group_name = azurerm_resource_group.front_end_rg.name
}

# Define storage share for the Windows-based function app
resource "azurerm_storage_share" "products_service_fa" {
  name  = "fa-products-service-share"
  quota = 2
  storage_account_name = azurerm_storage_account.products_service_fa.name
}
