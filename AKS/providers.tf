terraform {
  required_version = ">=1.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "AzureAKSLabs_Arul"
    workspaces {
      name = "Azure_Store_2026" 
    }
  }
}

provider "azurerm" {
  features {}
}

# Create AKS with Premium + LTS via azapi (ARM)
resource "azapi_resource" "aks_lts" {
  type      = "Microsoft.ContainerService/managedClusters@2024-02-01" # recent API version
  name      = random_pet.azurerm_kubernetes_cluster_name.id
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  # ARM properties for AKS
  body = jsonencode({
    sku = {
      name = "Base"
      tier = "Premium"                     # <-- Premium tier
    }
    properties = {
      dnsPrefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id
      kubernetesVersion  = "1.30.6"        # <-- LTS-only version
      supportPlan        = "LTS"           # <-- LTS support plan

      identity = {
        type = "SystemAssigned"
      }

      agentPoolProfiles = [{
        name                = "agentpool"
        count               = var.node_count
        vmSize              = "Standard_A2_v2"
        osType              = "Linux"
        mode                = "System"
        type                = "VirtualMachineScaleSets"
      }]

      linuxProfile = {
        adminUsername = var.username
        ssh = {
          publicKeys = [{
            keyData = azapi_resource_action.ssh_public_key_gen.output.publicKey
          }]
        }
      }

      networkProfile = {
        networkPlugin    = "kubenet"
        loadBalancerSku  = "standard"
      }
    }
  })

  # Optional: wait until provisioning succeeds
  response_export_values = ["properties.provisioningState", "properties.kubernetesVersion"]
}
