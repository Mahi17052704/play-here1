provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "AnkitTest" {
 name     = "AnkitTest"
 location = "West Europe"
}


resource "azurerm_virtual_network" "AnkitTestVnet" {
  name                = "AnkitTest-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.AnkitTest.location
  resource_group_name = azurerm_resource_group.AnkitTest.name
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.AnkitTest.name
  virtual_network_name = azurerm_virtual_network.AnkitTestVnet.name
  address_prefixes     = ["10.1.0.0/24"]
}


resource "azurerm_network_interface" "dsrvsqlankit02839" {
  name                = "dsrvsqlankit02839"
  location            = azurerm_resource_group.AnkitTest.location
  resource_group_name = azurerm_resource_group.AnkitTest.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_virtual_machine" "main" {
  name                = "DSRVSQLANKIT02"
  resource_group_name = azurerm_resource_group.AnkitTest.name
  location            = azurerm_resource_group.AnkitTest.location
  vm_size             = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.dsrvsqlankit02839.id]

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-datacenter-gensecond"
    version   = "latest"
  }
  storage_os_disk {
    name              = "DSRVSQLANKIT02_OsDisk_1_07740cc448d54da0a4dc445fdd142d11"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

   os_profile {
    computer_name  = "DSRVSQLANKIT02"
    admin_username = "Ankit"
    admin_password = "Ankit1234!"
  }
  os_profile_windows_config {
    
  }
}


resource "azurerm_monitor_action_group" "ActionGroup" {
  name                = "alerts vm ankittest1"
  resource_group_name = azurerm_resource_group.AnkitTest.name
  short_name          = "alerts1"

  email_receiver {
    name                    = "Martin Lundberg Arildsen"
    email_address           = "marar@telmore.dk"
    use_common_alert_schema = true
  }

  email_receiver {
    name                    = "Mads Mohr Christensen"
    email_address           = "mmc@telmore.dk"
    use_common_alert_schema = true
  }

  email_receiver {
    name                    = "Indrajit Mukherjee"
    email_address           = "indm@telmore.dk"
    use_common_alert_schema = true
  }

  email_receiver {
    name                    = "Ankit Kumar"
    email_address           = "akka@telmore.dk"
    use_common_alert_schema = true
  }

}

resource "azurerm_monitor_metric_alert" "alert" {
  name                = "VM_CPU_Dev_ANKITTest1"
  resource_group_name = azurerm_resource_group.AnkitTest.name
  scopes              = [azurerm_virtual_machine.main.id]
  description         = "Action will be triggered when CPU count is greater than 80."

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 80


  }

  action {
    action_group_id = azurerm_monitor_action_group.ActionGroup.id
  }
}
