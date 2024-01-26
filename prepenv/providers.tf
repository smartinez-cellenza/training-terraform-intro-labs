
provider "azurerm" {


  skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  
  }

  subscription_id = var.AzureSubscriptionID
  tenant_id       = var.AzureTenantID
  client_id       = var.AzureClientID
  client_secret   = var.AzureClientSecret

}

provider "azurerm" {


  skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  alias = "trainingroom1"

  subscription_id = "f6610597-eaad-438e-b014-4fdf3c18b762"
  tenant_id       = var.AzureTenantID
  client_id       = var.AzureClientID
  client_secret   = var.AzureClientSecret

}

