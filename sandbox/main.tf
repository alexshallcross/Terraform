####################
#### APIC Login ####
####################

provider "aci" {
  username = var.a_username
  password = var.b_password
  url      = "https://devasc-aci-1.cisco.com"
  insecure = false
}

#################
#### Modules ####
#################

module "fabric_base" {
  source = "./modules/fabric-base"

  spine_nodes      = [1001, 1002]
  bgp_as_number    = 65515
  ntp_auth_key     = "asdasdasd"
  inband_mgmt_vlan = 10

  inband_mgmt_rtr_ids = {
    901 = "10.41.37.2"
    902 = "10.41.37.10"
    903 = "10.41.37.18"
    904 = "10.41.37.26"
  }
  inband_mgmt_ospf_interface_vlan = 3900

  inband_mgmt_ospf_interface_list = {
    node_901_33 = {
      node_id      = 901
      interface_id = "eth1/33"
      addr         = "10.41.36.2/30"
    },
    node_901_34 = {
      node_id      = 901
      interface_id = "eth1/34"
      addr         = "10.41.36.6/30"
    },
    node_902_33 = {
      node_id      = 902
      interface_id = "eth1/33"
      addr         = "10.41.36.10/30"
    },
    node_902_34 = {
      node_id      = 902
      interface_id = "eth1/34"
      addr         = "10.41.36.14/30"
    },
    node_903_33 = {
      node_id      = 903
      interface_id = "eth1/33"
      addr         = "10.41.36.18/30"
    },
    node_903_34 = {
      node_id      = 903
      interface_id = "eth1/34"
      addr         = "10.41.36.22/30"
    },
    node_904_33 = {
      node_id      = 904
      interface_id = "eth1/33"
      addr         = "10.41.36.26/30"
    },
    node_904_34 = {
      node_id      = 904
      interface_id = "eth1/34"
      addr         = "10.41.36.30/30"
    }
  }

  inband_mgmt_subnet_gateway = "10.41.1.1/25"

  inband_mgmt_node_address = {
    1 = "10.41.1.11/25"
    2 = "10.41.1.12/25"
    3 = "10.41.1.13/25"
    1001 = "10.41.1.21/25"
    1002 = "10.41.1.22/25"
    1003 = "10.41.1.23/25"
    1004 = "10.41.1.24/25"
    901 = "10.41.1.31/25"
    902 = "10.41.1.32/25"
    903 = "10.41.1.33/25"
    904 = "10.41.1.34/25"
    101 = "10.41.1.51/25"
    102 = "10.41.1.52/25"
    103 = "10.41.1.53/25"
    104 = "10.41.1.54/25"
  }

  assured_ukcloud_mgmt_rtr_ids = {
    901 = "10.41.3.66"
    902 = "10.41.3.74"
    903 = "10.41.3.82"
    904 = "10.41.3.90"
  }
  assured_ukcloud_mgmt_ospf_interface_vlan = 3964

  assured_ukcloud_mgmt_ospf_interface_list = {
    node_901_17 = {
      node_id      = 901
      interface_id = "eth1/17"
      addr         = "10.41.0.66/30"
    },
    node_901_18 = {
      node_id      = 901
      interface_id = "eth1/18"
      addr         = "10.41.0.70/30"
    },
    node_902_17 = {
      node_id      = 902
      interface_id = "eth1/17"
      addr         = "10.41.0.78/30"
    },
    node_902_18 = {
      node_id      = 902
      interface_id = "eth1/18"
      addr         = "10.41.0.74/30"
    },
    node_903_17 = {
      node_id      = 903
      interface_id = "eth1/17"
      addr         = "10.41.0.82/30"
    },
    node_903_18 = {
      node_id      = 903
      interface_id = "eth1/18"
      addr         = "10.41.0.86/30"
    },
    node_904_17 = {
      node_id      = 904
      interface_id = "eth1/17"
      addr         = "10.41.0.90/30"
    },
    node_904_18 = {
      node_id      = 904
      interface_id = "eth1/18"
      addr         = "10.41.0.94/30"
    }
  }

  assured_ukcloud_mgmt_ospf_area_id = "0.0.0.5"

}

/***

module "pod00420" {
  source = "./modules/vmware-pod"
  pod_id = "pod00420"

  interface_map = {
    leafs_301_302 = {
      node_ids   = [301, 302]
      clnt_ports = [1, 2, 3, 4]
      mgmt_ports = [23, 24]
      cimc_ports = [30]
    },
    leafs_303_304 = {
      node_ids   = [303, 304]
      clnt_ports = [1, 2]
      mgmt_ports = []
      cimc_ports = []
    }
  }

  lldp_policy       = "default"
  cdp_policy        = "default"
  link_level_policy = "default"

  ukcloud_mgmt_tenant = "burgers"
  ukcloud_mgmt_l3_out = "burgers"
  ukcloud_mgmt_vrf    = "burgers"

  protection_tenant = "hotdogs"
  protection_l3_out = "hotdogs"
  protection_vrf    = "hotdogs"

  cimc_subnets = [
    "10.0.0.1/24"
  ]
  client_cluster_1_vmotion_subnets = [
    "10.0.1.1/24"
  ]
  client_cluster_1_vmware_subnets = [
    "10.0.2.1/24"
  ]
  client_cluster_1_vxlan_subnets = [
    "10.0.3.1/24"
  ]
  mgmt_cluster_avamar_subnets = [
    "10.0.4.1/24"
  ]
  mgmt_cluster_tools_subnets = [
    "10.0.5.1/24"
  ]
  mgmt_cluster_vmotion_subnets = [
    "10.0.6.1/24"
  ]
  mgmt_cluster_vmware_subnets = [
    "10.0.7.1/24"
  ]
  storage_mgmt_subnets = [
    "10.0.8.1/24"
  ]
  mgmt_vmm_subnets = [
    "10.0.9.1/24"
  ]
  client_avamar_subnets = [
    "10.0.10.1/24"
  ]
}

/***
module "openstack" {
  source   = "./modules/openstack-pod"
  for_each = var.openstack_pods

  pod_id    = each.value.pod_id
  pod_nodes = each.value.pod_nodes

  ukcloud_mgmt_tenant = each.value.ukcloud_mgmt_tenant
  ukcloud_mgmt_l3_out = each.value.ukcloud_mgmt_l3_out
  ukcloud_mgmt_vrf    = each.value.ukcloud_mgmt_vrf

  internal_api_bd_subnet      = each.value.internal_api_bd_subnet
  ipmi_bd_subnet              = each.value.ipmi_bd_subnet
  mgmt_bd_subnet              = each.value.mgmt_bd_subnet
  mgmt_provisioning_bd_subnet = each.value.mgmt_provisioning_bd_subnet
  storage_bd_subnet           = each.value.storage_bd_subnet
  storage_mgmt_bd_subnet      = each.value.storage_mgmt_bd_subnet
  tenant_bd_subnet            = each.value.tenant_bd_subnet
  mgmt_openstack_bd_subnet    = each.value.mgmt_openstack_bd_subnet
}
***/