provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "petclinic_rg" {
  name     = "petclinic-rg"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "petclinic_aks" {
  name                = "petclinic-aks"
  location           = azurerm_resource_group.petclinic_rg.location
  resource_group_name = azurerm_resource_group.petclinic_rg.name
  dns_prefix         = "petclinic"

  default_node_pool {
    name       = "agentpool"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
