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

  spine_nodes   = [1001, 1002]
  bgp_as_number = 65515
  ntp_auth_key  = "asdasdasd"
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