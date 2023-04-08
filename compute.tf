resource "azurerm_public_ip" "az_public_ip" {
  name                = var.vm_nic_info.public_ip_name
  resource_group_name = azurerm_resource_group.azrg.name
  location            = azurerm_resource_group.azrg.location
  allocation_method   = var.vm_nic_info.public_ip_allocation
}
resource "azurerm_network_interface" "aznic" {
  name                = var.vm_nic_info.nic_name
  resource_group_name = azurerm_resource_group.azrg.name
  location            = azurerm_resource_group.azrg.location
  ip_configuration {
    name                          = var.vm_nic_info.nic_ip_name
    subnet_id                     = azurerm_subnet.azsubnet.id
    private_ip_address_allocation = var.vm_nic_info.nic_ip_allocation
    public_ip_address_id          = azurerm_public_ip.az_public_ip.id
  }
  depends_on = [
    azurerm_resource_group.azrg,
    azurerm_virtual_network.azvnet,
    azurerm_subnet.azsubnet
  ]

}
resource "azurerm_linux_virtual_machine" "azvm" {
  name                            = var.vm_info.vm_name
  resource_group_name             = azurerm_resource_group.azrg.name
  location                        = azurerm_resource_group.azrg.location
  size                            = var.vm_info.vm_size
  admin_username                  = var.vm_info.vm_username
  admin_password                  = var.vm_info.vm_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.aznic.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.image_info.publisher
    offer     = var.image_info.offer
    sku       = var.image_info.sku
    version   = var.image_info.version
  }
  depends_on = [
    azurerm_network_interface.aznic
  ]
}

