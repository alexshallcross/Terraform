######################
#### Data Sources ####
######################

data "aci_fabric_if_pol" "link_level" {
  name = var.link_level_policy
}
data "aci_cdp_interface_policy" "cdp_enabled" {
  name = var.cdp_policy
}

data "aci_lldp_interface_policy" "lldp_enabled" {
  name = var.lldp_policy
}

data "aci_tenant" "ukcloud_mgmt" {
  name = var.ukcloud_mgmt_tenant
}

data "aci_l3_outside" "ukcloud_mgmt" {
  tenant_dn = data.aci_tenant.ukcloud_mgmt.id
  name      = var.ukcloud_mgmt_l3_out
}

data "aci_vrf" "ukcloud_mgmt" {
  tenant_dn = data.aci_tenant.ukcloud_mgmt.id
  name      = var.ukcloud_mgmt_vrf
}



#########################
#### Local Variables ####
#########################

locals {
  flattened_client_interface_map = flatten([
    for pair_key, pair in var.interface_map : [
      for clnt_port in pair.clnt_ports : {
        pair_key  = pair_key
        clnt_port = clnt_port
      }
    ]
  ])
  flattened_mgmt_interface_map = flatten([
    for pair_key, pair in var.interface_map : [
      for mgmt_port in pair.mgmt_ports : {
        pair_key  = pair_key
        mgmt_port = mgmt_port
      }
    ]
  ])
  flattened_cimc_interface_map = flatten([
    for pair_key, pair in var.interface_map : [
      for cimc_port in pair.cimc_ports : {
        pair_key  = pair_key
        cimc_port = cimc_port
      }
    ]
  ])
}



########################
#### Switch Profile ####
########################

resource "aci_leaf_profile" "vmware" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_vmware_", each.key])

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.client_esx[each.key].id,
    aci_leaf_interface_profile.mgmt_esx[each.key].id,
    aci_leaf_interface_profile.cimc[each.key].id
  ]
}

resource "aci_leaf_selector" "vmware" {
  for_each = var.interface_map

  leaf_profile_dn         = aci_leaf_profile.vmware[each.key].id
  name                    = join("", [var.pod_id, "_vmware_", each.key])
  switch_association_type = "range"
}

resource "aci_node_block" "vmware" {
  for_each = var.interface_map

  switch_association_dn = aci_leaf_selector.vmware[each.key].id

  name  = join("", [var.pod_id, "_", each.key])
  from_ = each.value.node_ids[0]
  to_   = each.value.node_ids[1]
}



######################################
#### Client ESX Interface Profile ####
######################################

resource "aci_leaf_interface_profile" "client_esx" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_", each.key, "_client_esx"])
}

resource "aci_access_port_selector" "client_esx" {
  for_each = var.interface_map

  leaf_interface_profile_dn      = aci_leaf_interface_profile.client_esx[each.key].id
  name                           = join("", [var.pod_id, "_", each.key, "_client_esx"])
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.client_esx.id
}

resource "aci_access_port_block" "client_esx" {
  for_each = {
    for interface in local.flattened_client_interface_map : "${interface.pair_key}.${interface.clnt_port}" => interface
  }

  access_port_selector_dn = aci_access_port_selector.client_esx[each.value.pair_key].id
  name                    = join("", [var.pod_id, "_", each.value.pair_key, "_port_", each.value.clnt_port])
  from_port               = each.value.clnt_port
  to_port                 = each.value.clnt_port
}



##########################################
#### Management ESX Interface Profile ####
##########################################

resource "aci_leaf_interface_profile" "mgmt_esx" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_", each.key, "_mgmt_esx"])
}

resource "aci_access_port_selector" "mgmt_esx" {
  for_each = var.interface_map

  leaf_interface_profile_dn      = aci_leaf_interface_profile.mgmt_esx[each.key].id
  name                           = join("", [var.pod_id, "_", each.key, "_mgmt_esx"])
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.mgmt_esx.id
}

resource "aci_access_port_block" "mgmt_esx" {
  for_each = {
    for interface in local.flattened_mgmt_interface_map : "${interface.pair_key}.${interface.mgmt_port}" => interface
  }

  access_port_selector_dn = aci_access_port_selector.mgmt_esx[each.value.pair_key].id
  name                    = join("", [var.pod_id, "_", each.value.pair_key, "_port_", each.value.mgmt_port])
  from_port               = each.value.mgmt_port
  to_port                 = each.value.mgmt_port
}



################################
#### CIMC Interface Profile ####
################################

resource "aci_leaf_interface_profile" "cimc" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_", each.key, "_cimc"])
}

resource "aci_access_port_selector" "cimc" {
  for_each = var.interface_map

  leaf_interface_profile_dn      = aci_leaf_interface_profile.cimc[each.key].id
  name                           = join("", [var.pod_id, "_", each.key, "_cimc"])
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_bundle_policy_group.cimc.id
}

resource "aci_access_port_block" "cimc" {
  for_each = {
    for interface in local.flattened_cimc_interface_map : "${interface.pair_key}.${interface.cimc_port}" => interface
  }

  access_port_selector_dn = aci_access_port_selector.cimc[each.value.pair_key].id
  name                    = join("", [var.pod_id, "_", each.value.pair_key, "_port_", each.value.cimc_port])
  from_port               = each.value.cimc_port
  to_port                 = each.value.cimc_port
}



###########################################
#### Client ESX Interface Policy Group ####
###########################################

resource "aci_leaf_access_port_policy_group" "client_esx" {
  name = join("", [var.pod_id, "_client_esx"])

  relation_infra_rs_h_if_pol    = data.aci_fabric_if_pol.link_level.id
  relation_infra_rs_cdp_if_pol  = data.aci_cdp_interface_policy.cdp_enabled.id
  relation_infra_rs_lldp_if_pol = data.aci_lldp_interface_policy.lldp_enabled.id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.client_esx.id
}



###############################################
#### Management ESX Interface Policy Group ####
###############################################

resource "aci_leaf_access_port_policy_group" "mgmt_esx" {
  name = join("", [var.pod_id, "_mgmt_esx"])

  relation_infra_rs_h_if_pol    = data.aci_fabric_if_pol.link_level.id
  relation_infra_rs_cdp_if_pol  = data.aci_cdp_interface_policy.cdp_enabled.id
  relation_infra_rs_lldp_if_pol = data.aci_lldp_interface_policy.lldp_enabled.id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.mgmt_esx.id
}



###############################
#### CIMC VPC Policy Group ####
###############################

resource "aci_leaf_access_bundle_policy_group" "cimc" {
  name  = join("", [var.pod_id, "_cimc"])
  lag_t = "node"

  relation_infra_rs_h_if_pol    = data.aci_fabric_if_pol.link_level.id
  relation_infra_rs_cdp_if_pol  = data.aci_cdp_interface_policy.cdp_enabled.id
  relation_infra_rs_lldp_if_pol = data.aci_lldp_interface_policy.lldp_enabled.id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.cimc.id
}



###############################
#### VPC Protection Policy ####
###############################

resource "aci_vpc_explicit_protection_group" "vpc_protection" {
  for_each = var.interface_map

  name    = join("", [var.pod_id, "_", each.key])
  switch1 = each.value.node_ids[0]
  switch2 = each.value.node_ids[1]

  vpc_explicit_protection_group_id = each.value.node_ids[0]
}



###########################################
#### Attachable Access Entity Profiles ####
###########################################

resource "aci_attachable_access_entity_profile" "client_esx" {
  name = join("", [var.pod_id, "_client_esx"])
  relation_infra_rs_dom_p = [
    aci_physical_domain.vmware.id
  ]
}

resource "aci_access_generic" "client_esx" {
  name = "default"

  attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.client_esx.id
}

resource "aci_attachable_access_entity_profile" "mgmt_esx" {
  name = join("", [var.pod_id, "_mgmt_esx"])
  relation_infra_rs_dom_p = [
    aci_physical_domain.vmware.id
  ]
}

resource "aci_access_generic" "mgmt_esx" {
  name = "default"

  attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.mgmt_esx.id
}

resource "aci_attachable_access_entity_profile" "cimc" {
  name = join("", [var.pod_id, "_cimc"])
  relation_infra_rs_dom_p = [
    aci_physical_domain.vmware.id
  ]
}

resource "aci_access_generic" "cimc" {
  name = "default"

  attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.cimc.id
}



##########################
#### Physical Domains ####
##########################

resource "aci_physical_domain" "vmware" {
  name = join("", [var.pod_id, "_vmware"])

  relation_infra_rs_vlan_ns = aci_vlan_pool.vmware_static.id
}



####################
#### VLAN Pools ####
####################

resource "aci_vlan_pool" "vmware_static" {
  name       = join("", [var.pod_id, "_vmware_static"])
  alloc_mode = "static"
}

resource "aci_ranges" "vmware_static_range1" {
  vlan_pool_dn = aci_vlan_pool.vmware_static.id
  from         = "vlan-1"
  to           = "vlan-999"
  alloc_mode   = "static"
  role         = "external"
}

resource "aci_vlan_pool" "vmm_dynamic" {
  name       = join("", [var.pod_id, "_vmm_dynamic"])
  alloc_mode = "dynamic"
}

resource "aci_ranges" "vmware_dynamic_range1" {
  vlan_pool_dn = aci_vlan_pool.vmm_dynamic.id
  from         = "vlan-1000"
  to           = "vlan-1999"
  alloc_mode   = "dynamic"
  role         = "external"
}



#############################
#### Application Profile ####
#############################

resource "aci_application_profile" "vmware" {
  tenant_dn = data.aci_tenant.ukcloud_mgmt.id
  name      = join("", [var.pod_id, "_vmware"])
}

#################
#### EPG/BDs ####
#################

module "cimc" {
  source = "./modules/epg-bd-config"

  epg_name = "cimc"
  vlan_tag = "vlan-100"
  subnets  = var.cimc_subnets
  access_generic_id = aci_access_generic.cimc.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "storage_mgmt" {
  source = "./modules/epg-bd-config"

  epg_name          = "storage_mgmt"
  vlan_tag          = "vlan-118"
  subnets           = var.storage_mgmt_subnets
  access_generic_id = aci_access_generic.cimc.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "mgmt_cluster_vmware" {
  source = "./modules/epg-bd-config"
  
  epg_name          = "mgmt_cluster_vmware"
  vlan_tag          = "vlan-101"
  subnets           = var.mgmt_cluster_vmware_subnets
  access_generic_id = aci_access_generic.mgmt_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "mgmt_cluster_tools" {
  source = "./modules/epg-bd-config"
  
  epg_name          = "mgmt_cluster_tools"
  vlan_tag          = "vlan-102"
  subnets           = var.mgmt_cluster_tools_subnets
  access_generic_id = aci_access_generic.mgmt_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "mgmt_cluster_vmotion" {
  source = "./modules/epg-bd-config"
  
  epg_name          = "mgmt_cluster_vmotion"
  vlan_tag          = "vlan-104"
  subnets           = var.mgmt_cluster_vmotion_subnets
  access_generic_id = aci_access_generic.mgmt_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "client_cluster_1_vmotion" {
  source = "./modules/epg-bd-config"
  
  epg_name          = "client_cluster_1_vmotion"
  vlan_tag          = "vlan-104"
  subnets           = var.client_cluster_1_vmotion_subnets
  access_generic_id = aci_access_generic.client_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "client_cluster_1_vmware" {
  source = "./modules/epg-bd-config"
  
  epg_name          = "client_cluster_1_vmware"
  vlan_tag          = "vlan-104"
  subnets           = var.client_cluster_1_vmware_subnets
  access_generic_id = aci_access_generic.client_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "client_cluster_1_vxlan" {
  source = "./modules/epg-bd-config"
  
  epg_name          = "client_cluster_1_vxlan"
  vlan_tag          = "vlan-115"
  subnets           = var.client_cluster_1_vxlan_subnets
  access_generic_id = aci_access_generic.client_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}

module "mgmt_cluster_avamar" {
  source = "./modules/epg-bd-config"
  
  epg_name          = "mgmt_cluster_avamar"
  vlan_tag          = "vlan-156"
  subnets           = var.mgmt_cluster_avamar_subnets
  access_generic_id = aci_access_generic.client_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = data.aci_tenant.ukcloud_mgmt.id
  l3_out   = data.aci_l3_outside.ukcloud_mgmt.id
  vrf      = data.aci_vrf.ukcloud_mgmt.id
}