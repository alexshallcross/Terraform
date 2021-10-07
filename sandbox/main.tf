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
  source = "./modules/fabric_base"

  spine_nodes      = [1001, 1002]
  bgp_as_number    = 65515
  ntp_auth_key     = "asdasdasd"
  inband_mgmt_vlan = 10

  inband_mgmt_ospf_interface_vlan = 3900

  inband_mgmt_subnet_gateway = "10.41.1.1/25"

  inband_mgmt_node_address = {
    1    = "10.41.1.11/25"
    2    = "10.41.1.12/25"
    3    = "10.41.1.13/25"
    1001 = "10.41.1.21/25"
    1002 = "10.41.1.22/25"
    1003 = "10.41.1.23/25"
    1004 = "10.41.1.24/25"
    901  = "10.41.1.31/25"
    902  = "10.41.1.32/25"
    903  = "10.41.1.33/25"
    904  = "10.41.1.34/25"
    101  = "10.41.1.51/25"
    102  = "10.41.1.52/25"
    103  = "10.41.1.53/25"
    104  = "10.41.1.54/25"
  }

  inband_mgmt_ospf = {
    901 = {
      router_id = "10.41.37.2"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.2/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.6/30"
        }
      ]
    },
    902 = {
      router_id = "10.41.37.10"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.10/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.14/30"
        }
      ]
    },
    903 = {
      router_id = "10.41.37.18"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.18/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.22/30"
        }
      ]
    },
    904 = {
      router_id = "10.41.37.26"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.26/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.30/30"
        }
      ]
    }
  }

  assured_private_peering_domains = toset([
    #module.assured_psn.aci_assured_psn_aep_domain
  ])
}
/***
module "assured_underlay_transport" {
  source = "./modules/assured_underlay_transport"

  assured_underlay_transport_ospf_interface_vlan = 3963
  assured_underlay_transport_ospf_area_id        = "0.0.0.6"

  assured_underlay_transport_ospf = {
    901 = {
      router_id = "10.40.42.2"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.64.6.2/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.64.6.6/30"
        },
        {
          interface_id = "eth1/21"
          address      = "100.64.6.33/30"
        },
        {
          interface_id = "eth1/22"
          address      = "100.64.6.49/30"
        }
      ]
    },
    902 = {
      router_id = "10.40.42.10"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.64.6.14/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.64.6.10/30"
        },
        {
          interface_id = "eth1/21"
          address      = "100.64.6.37/30"
        },
        {
          interface_id = "eth1/22"
          address      = "100.64.6.53/30"
        }
      ]
    },
    903 = {
      router_id = "10.40.42.18"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.64.6.18/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.64.6.22/30"
        },
        {
          interface_id = "eth1/21"
          address      = "100.64.6.41/30"
        },
        {
          interface_id = "eth1/22"
          address      = "100.64.6.57/30"
        }
      ]
    },
    904 = {
      router_id = "10.40.42.26"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.64.6.26/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.64.6.30/30"
        },
        {
          interface_id = "eth1/21"
          address      = "100.64.6.45/30"
        },
        {
          interface_id = "eth1/22"
          address      = "100.64.6.61/30"
        }
      ]
    }
  }

  interface_speed_policy = module.fabric_base.aci_fabric_if_pol_10G
  interface_cdp_policy   = module.fabric_base.aci_cdp_interface_policy_disabled
  interface_lldp_policy  = module.fabric_base.aci_lldp_interface_policy_enabled
}
***/
/***
module "assured_ukcloud_mgmt" {
  source = "./modules/assured_ukcloud_mgmt"

  assured_ukcloud_mgmt_ospf_interface_vlan = 3964
  assured_ukcloud_mgmt_ospf_area_id        = "0.0.0.5"
  assured_ukcloud_mgmt_ospf = {
    901 = {
      router_id = "10.41.3.66"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "10.41.0.66/30"
        },
        {
          interface_id = "eth1/18"
          address      = "10.41.0.70/30"
        }
      ]
    },
    902 = {
      router_id = "10.41.3.74"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "10.41.0.78/30"
        },
        {
          interface_id = "eth1/18"
          address      = "10.41.0.74/30"
        }
      ]
    },
    903 = {
      router_id = "10.41.3.82"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "10.41.0.82/30"
        },
        {
          interface_id = "eth1/18"
          address      = "10.41.0.86/30"
        }
      ]
    },
    904 = {
      router_id = "10.41.3.90"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "10.41.0.90/30"
        },
        {
          interface_id = "eth1/18"
          address      = "10.41.0.94/30"
        }
      ]
    }
  }
}
***/
/***
module "elevated_underlay_transport" {
  source = "./modules/elevated_underlay_transport"

  elevated_underlay_transport_ospf_interface_vlan = 3963
  elevated_underlay_transport_ospf_area_id        = "0.0.0.6"

  elevated_underlay_transport_ospf = {
    901 = {
      router_id = "10.40.45.2"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "100.66.0.2/30"
        },
        {
          interface_id = "eth1/34"
          address      = "100.66.0.6/30"
        },
        {
          interface_id = "eth1/37"
          address      = "100.66.0.33/30"
        },
        {
          interface_id = "eth1/38"
          address      = "100.66.0.49/30"
        }
      ]
    },
    902 = {
      router_id = "10.40.45.10"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "100.66.0.14/30"
        },
        {
          interface_id = "eth1/34"
          address      = "100.66.0.10/30"
        },
        {
          interface_id = "eth1/37"
          address      = "100.66.0.37/30"
        },
        {
          interface_id = "eth1/38"
          address      = "100.66.0.53/30"
        }
      ]
    },
    903 = {
      router_id = "10.40.45.18"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "100.66.0.18/30"
        },
        {
          interface_id = "eth1/34"
          address      = "100.66.0.22/30"
        },
        {
          interface_id = "eth1/37"
          address      = "100.66.0.41/30"
        },
        {
          interface_id = "eth1/38"
          address      = "100.66.0.57/30"
        }
      ]
    },
    904 = {
      router_id = "10.40.45.26"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "100.66.0.26/30"
        },
        {
          interface_id = "eth1/34"
          address      = "100.66.0.30/30"
        },
        {
          interface_id = "eth1/37"
          address      = "100.66.0.45/30"
        },
        {
          interface_id = "eth1/38"
          address      = "100.66.0.61/30"
        }
      ]
    }
  }

  interface_speed_policy = module.fabric_base.aci_fabric_if_pol_10G
  interface_cdp_policy   = module.fabric_base.aci_cdp_interface_policy_disabled
  interface_lldp_policy  = module.fabric_base.aci_lldp_interface_policy_enabled
}
***/
/***
module "assured_protection" {
  source = "./modules/assured_protection"

  assured_protection_ospf_interface_vlan = 3963
  assured_protection_ospf_area_id        = "0.0.0.6"

  assured_protection_ospf = {
    901 = {
      router_id = "10.41.35.66"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.162/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.166/30"
        }
      ]
    },
    902 = {
      router_id = "10.41.35.74"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.174/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.170/30"
        }
      ]
    },
    903 = {
      router_id = "10.41.35.82"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.178/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.182/30"
        }
      ]
    },
    904 = {
      router_id = "10.41.35.90"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.186/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.190/30"
        }
      ]
    }
  }
}
***/ #
/***
module "assured_psn" {
  source = "./modules/assured_psn"

  assured_psn_ospf_interface_vlan = 3961
  assured_psn_ospf_area_id        = "0.0.0.6"

  assured_psn_ospf = {
    901 = {
      router_id = "10.41.35.66"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.162/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.166/30"
        }
      ]
    },
    902 = {
      router_id = "10.41.35.74"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.174/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.170/30"
        }
      ]
    },
    903 = {
      router_id = "10.41.35.82"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.178/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.182/30"
        }
      ]
    },
    904 = {
      router_id = "10.41.35.90"
      interfaces = [
        {
          interface_id = "eth1/17"
          address      = "100.65.0.186/30"
        },
        {
          interface_id = "eth1/18"
          address      = "100.65.0.190/30"
        }
      ]
    }
  }
}
***/
module "combined_services" {
  source = "./modules/combined_services"

  assured_combined_services_bgp_interface_vlan  = 3957
  elevated_combined_services_bgp_interface_vlan = 3957

  assured_combined_services_bgp = {
    901 = {
      router_id = "10.42.0.66"
      interfaces = [
        {
          interface_id  = "eth1/17"
          address       = "10.42.0.113/30"
          bgp_peer      = "10.42.0.114"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        },
        {
          interface_id  = "eth1/18"
          address       = "10.42.0.117/30"
          bgp_peer      = "10.42.0.118"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        }
      ]
    },
    902 = {
      router_id = "10.42.0.74"
      interfaces = [
        {
          interface_id  = "eth1/17"
          address       = "10.42.0.105/30"
          bgp_peer      = "10.42.0.106"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        },
        {
          interface_id  = "eth1/18"
          address       = "10.42.0.109/30"
          bgp_peer      = "10.42.0.110"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        }
      ]
    }
  }

  elevated_combined_services_bgp = {
    901 = {
      router_id = "10.42.0.66"
      interfaces = [
        {
          interface_id  = "eth1/33"
          address       = "10.42.0.101/30"
          bgp_peer      = "10.42.0.102"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        },
        {
          interface_id  = "eth1/34"
          address       = "10.42.0.97/30"
          bgp_peer      = "10.42.0.98"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        }
      ]
    },
    902 = {
      router_id = "10.42.0.74"
      interfaces = [
        {
          interface_id  = "eth1/33"
          address       = "10.42.0.93/30"
          bgp_peer      = "10.42.0.94"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        },
        {
          interface_id  = "eth1/34"
          address       = "10.42.0.89/30"
          bgp_peer      = "10.42.0.90"
          bgp_asn       = 65000
          bgp_local_asn = 65513
        }
      ]
    }
  }
}
/***
module "elevated_ukcloud_mgmt" {
  source = "./modules/elevated_ukcloud_mgmt"

  elevated_ukcloud_mgmt_ospf_interface_vlan = 3964
  elevated_ukcloud_mgmt_ospf_area_id        = "0.0.0.5"
  elevated_ukcloud_mgmt_ospf = {
    901 = {
      router_id = "10.41.38.66"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.66/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.70/30"
        }
      ]
    },
    902 = {
      router_id = "10.41.38.74"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.78/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.74/30"
        }
      ]
    },
    903 = {
      router_id = "10.41.38.82"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.82/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.86/30"
        }
      ]
    },
    904 = {
      router_id = "10.41.38.90"
      interfaces = [
        {
          interface_id = "eth1/33"
          address      = "10.41.36.90/30"
        },
        {
          interface_id = "eth1/34"
          address      = "10.41.36.94/30"
        }
      ]
    }
  }

}
***/
/***
module "pod00420" {
  source = "./modules/vmware_pod"
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
***/
/***
module "openstack" {
  source   = "./modules/openstack_pod"
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