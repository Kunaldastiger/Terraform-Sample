terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source = "hashicorp/azurerm"
      version = ">= 2.4.1"
    }
  }
}
provider "azurerm" {
  features {
      key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
data "azurerm_client_config" "current" {}
# Create our Resource Group - "Devops-RG"

# Create our Virtual Network - kunal-VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "kunalvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "Devops-RG"
}
# Create our Subnet to hold our VM - Virtual Machines
resource "azurerm_subnet" "sn" {
  name                 = "VM"
  resource_group_name  = "Devops-RG"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.0.1.0/24"]
}
# Create our Azure Storage Account - kunalsa
resource "azurerm_storage_account" "kunalsa" {
  name                     = "kunalsa"
  resource_group_name      = "Devops-RG"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "kunalrox"
  }
}
# Create our vNIC for our VM and assign it to our Virtual Machines Subnet
resource "azurerm_network_interface" "vmnic" {
  name                = "kunalvm01nic"
  location            = "East US"
  resource_group_name = "Devops-RG"
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create our Virtual Machine - kunal-VM01
resource "azurerm_virtual_machine" "kunalvm01" {
  name                  = "kunalvm01"
  location              = "East US"
  resource_group_name   = "Devops-RG"
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  vm_size               = "Standard_B1s"
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }
  storage_os_disk {
    name              = "kunalvm01os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name      = "kunalvm01"
    admin_username     = "kunal"
    admin_password     = "Password123$"
  }
  os_profile_windows_config {
  }
}



