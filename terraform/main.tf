resource "azurerm_resource_group" "vmcreation" {
  name     = "${var.VMName}-RG"
  location = "East US"
}

resource "azurerm_virtual_network" "vmcreation" {
  name                = "${var.VMName}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vmcreation.location
  resource_group_name = azurerm_resource_group.vmcreation.name
}

resource "azurerm_subnet" "vmcreation" {
  name                 = "${var.VMName}-internal"
  resource_group_name  = azurerm_resource_group.vmcreation.name
  virtual_network_name = azurerm_virtual_network.vmcreation.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmcreation" {
  name                    = "${var.VMName}-test-pip"
  location                = azurerm_resource_group.vmcreation.location
  resource_group_name     = azurerm_resource_group.vmcreation.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}

resource "azurerm_network_interface" "vmcreation" {
  name                = "${var.VMName}-nic"
  location            = azurerm_resource_group.vmcreation.location
  resource_group_name = azurerm_resource_group.vmcreation.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vmcreation.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vmcreation.id
  }
}

resource "azurerm_network_security_group" "vmcreation" {
  name                = "${var.VMName}-acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.vmcreation.location
  resource_group_name = azurerm_resource_group.vmcreation.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "vmcreation" {
  network_interface_id      = azurerm_network_interface.vmcreation.id
  network_security_group_id = azurerm_network_security_group.vmcreation.id
}


resource "azurerm_virtual_machine" "vmcreation" {
  name                  = var.VMName
  location              = azurerm_resource_group.vmcreation.location
  resource_group_name   = azurerm_resource_group.vmcreation.name
  network_interface_ids = [azurerm_network_interface.vmcreation.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.VMName
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    CommissionSR = var.SRNumber
  }
}