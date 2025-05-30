resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "cloud-sre-demo-rg"  # Updated resource group name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "sre-demo-aks-cluster"  # Updated AKS cluster name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "sre-demo-aks-cluster"  # Using the cluster name for consistency
  kubernetes_version  = "1.30.0"
}

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "standard_a2_v2"
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
