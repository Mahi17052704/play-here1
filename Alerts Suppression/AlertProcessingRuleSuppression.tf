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



resource "azurerm_monitor_alert_processing_rule_suppression" "AlertSuppression" {
  name                = "Maintenance_window_on_VM"
  resource_group_name = "AnkitTest"
  scopes              = [azurerm_resource_group.AnkitTest.id]

  condition {
  
    //target_resource_type {
    //operator = "Equals"
    // values   = ["Microsoft.Compute/virtualMachines"]
    //}
    // severity {
    //  operator = "Equals"
    //  values   = ["Sev0", "Sev1", "Sev2"]
    //}
  

    alert_rule_id {
        operator = "Equals"
       values = ["/subscriptions/8d96f14e-b8e7-4236-a75c-4b0a99245758/resourceGroups/AnkitTest/providers/Microsoft.Insights/metricAlerts/VM_CPU_Dev_ANKITTest1"]
    }

    alert_rule_name {
        operator = "Equals"
        values = ["VM_CPU_Dev_ANKITTest1"]
    }
      }


  schedule {
    effective_from  = "2022-10-03T01:02:03"
    effective_until = "2023-10-30T01:02:03"
    time_zone       = "Romance Standard Time"
    recurrence {
      daily {
        start_time = "17:00:00"
        end_time   = "09:00:00"
      }
      weekly {
        days_of_week = ["Saturday", "Sunday"]
      }
    }
  }
}
 