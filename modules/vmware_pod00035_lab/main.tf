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
}



########################
#### Switch Profile ####
########################

resource "aci_leaf_profile" "vmware" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_", each.key])

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.vmware[each.key].id
  ]
}

resource "aci_leaf_selector" "vmware" {
  for_each = var.interface_map

  leaf_profile_dn         = aci_leaf_profile.vmware[each.key].id
  name                    = join("", [var.pod_id, "_", each.key])
  switch_association_type = "range"
}

resource "aci_node_block" "vmware" {
  for_each = var.interface_map

  switch_association_dn = aci_leaf_selector.vmware[each.key].id

  name  = join("", [var.pod_id, "_", each.key])
  from_ = each.value.node_ids[0]
  to_   = each.value.node_ids[1]
}



###########################
#### Interface Profile ####
###########################

resource "aci_leaf_interface_profile" "vmware" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_", each.key])
}

resource "aci_access_port_selector" "client_esx" {
  for_each = var.interface_map

  leaf_interface_profile_dn      = aci_leaf_interface_profile.vmware[each.key].id
  name                           = join("", [var.pod_id, "_client_esx_40G_lldp_cdp"])
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.client_esx.id
}

resource "aci_access_port_block" "client_esx" {
  for_each = {
    for interface in local.flattened_client_interface_map : "${interface.pair_key}.${interface.clnt_port}" => interface
  }

  access_port_selector_dn = aci_access_port_selector.client_esx[each.value.pair_key].id
  name                    = join("", ["port_", each.value.clnt_port])
  from_port               = each.value.clnt_port
  to_port                 = each.value.clnt_port
}

resource "aci_access_port_selector" "mgmt_esx" {
  for_each = var.interface_map

  leaf_interface_profile_dn      = aci_leaf_interface_profile.vmware[each.key].id
  name                           = join("", [var.pod_id, "_mgmt_esx_40G_lldp_cdp"])
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.mgmt_esx.id
}

resource "aci_access_port_block" "mgmt_esx" {
  for_each = {
    for interface in local.flattened_mgmt_interface_map : "${interface.pair_key}.${interface.mgmt_port}" => interface
  }

  access_port_selector_dn = aci_access_port_selector.mgmt_esx[each.value.pair_key].id
  name                    = join("", ["port_", each.value.mgmt_port])
  from_port               = each.value.mgmt_port
  to_port                 = each.value.mgmt_port
}



###########################################
#### Client ESX Interface Policy Group ####
###########################################

resource "aci_leaf_access_port_policy_group" "client_esx" {
  name = join("", [var.pod_id, "_client_esx"])

  relation_infra_rs_h_if_pol    = var.link_level_policy
  relation_infra_rs_cdp_if_pol  = var.cdp_disabled_policy
  relation_infra_rs_lldp_if_pol = var.lldp_enabled_policy
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.client_esx.id
}



###############################################
#### Management ESX Interface Policy Group ####
###############################################

resource "aci_leaf_access_port_policy_group" "mgmt_esx" {
  name = join("", [var.pod_id, "_mgmt_esx"])

  relation_infra_rs_h_if_pol    = var.link_level_policy
  relation_infra_rs_cdp_if_pol  = var.cdp_disabled_policy
  relation_infra_rs_lldp_if_pol = var.lldp_enabled_policy
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.mgmt_esx.id
}



###########################################
#### Attachable Access Entity Profiles ####
###########################################

resource "aci_attachable_access_entity_profile" "client_esx" {
  name = join("", [var.pod_id, "_client_esx"])
  relation_infra_rs_dom_p = [
    aci_physical_domain.vmware.id,
    aci_vmm_domain.vmware.id
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
  tenant_dn = var.ukcloud_mgmt_tenant
  name      = join("", [var.pod_id, "_vmware"])
}

resource "aci_application_profile" "mgmt" {
  tenant_dn = "uni/tn-mgmt"
  name      = join("", [var.pod_id, "_management"])
}

resource "aci_application_profile" "avamar" {
  tenant_dn = var.protection_tenant
  name      = join("", [var.pod_id, "_avamar"])
}

######################
#### In Line CIMC ####
######################

resource "aci_application_epg" "cimc" {
  name                   = join("", [var.pod_id, "_cimc"])
  application_profile_dn = aci_application_profile.vmware.id
  relation_fv_rs_bd      = aci_bridge_domain.cimc.id
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_epg_to_domain" "cimc" {
  application_epg_dn = aci_application_epg.cimc.id
  tdn                = aci_physical_domain.vmware.id
}

resource "aci_epgs_using_function" "client_cimc_epg_to_aep" {
  access_generic_dn = aci_access_generic.client_esx.id
  tdn               = aci_application_epg.cimc.id
  encap             = "vlan-100"
  instr_imedcy      = "immediate"
  mode              = "native"
}

resource "aci_epgs_using_function" "mgmt_cimc_epg_to_aep" {
  access_generic_dn = aci_access_generic.mgmt_esx.id
  tdn               = aci_application_epg.cimc.id
  encap             = "vlan-100"
  instr_imedcy      = "immediate"
  mode              = "native"
}

resource "aci_bridge_domain" "cimc" {
  name                = join("", [var.pod_id, "_cimc"])
  tenant_dn           = var.ukcloud_mgmt_tenant
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    var.ukcloud_mgmt_l3_out
  ]
  relation_fv_rs_ctx = var.ukcloud_mgmt_vrf
}


resource "aci_subnet" "subnet" {
  for_each = toset(var.cimc_subnets)

  parent_dn = aci_bridge_domain.cimc.id
  ip        = each.value
  scope = [
    "public"
  ]
}

#################
#### EPG/BDs ####
#################

module "mgmt_cluster_tranit" {
  source = "./modules/epg-bd-config"

  epg_name          = "mgmt_cluster_tranit"
  vlan_tag          = "vlan-105"
  subnets           = var.mgmt_cluster_tranit_subnets
  access_generic_id = aci_access_generic.client_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = var.ukcloud_mgmt_tenant
  l3_out   = [var.ukcloud_mgmt_l3_out]
  vrf      = var.ukcloud_mgmt_vrf
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
  tenant   = var.ukcloud_mgmt_tenant
  l3_out   = [var.ukcloud_mgmt_l3_out]
  vrf      = var.ukcloud_mgmt_vrf
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
  tenant   = var.ukcloud_mgmt_tenant
  l3_out   = [var.ukcloud_mgmt_l3_out]
  vrf      = var.ukcloud_mgmt_vrf
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
  tenant   = var.ukcloud_mgmt_tenant
  l3_out   = [var.ukcloud_mgmt_l3_out]
  vrf      = var.ukcloud_mgmt_vrf
}

module "mgmt_cluster_vsan" {
  source = "./modules/epg-bd-config"

  epg_name          = "mgmt_cluster_vsan"
  vlan_tag          = "vlan-102"
  subnets           = var.mgmt_cluster_vsan_subnets
  access_generic_id = aci_access_generic.mgmt_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = var.ukcloud_mgmt_tenant
  l3_out   = [var.ukcloud_mgmt_l3_out]
  vrf      = var.ukcloud_mgmt_vrf
}

module "mgmt_cluster_edge_overlay" {
  source = "./modules/epg-bd-config"

  epg_name          = "mgmt_cluster_edge_overlay"
  vlan_tag          = "vlan-104"
  subnets           = var.mgmt_cluster_edge_overlay_subnets
  access_generic_id = aci_access_generic.mgmt_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.vmware.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = var.ukcloud_mgmt_tenant
  l3_out   = [var.ukcloud_mgmt_l3_out]
  vrf      = var.ukcloud_mgmt_vrf
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
  tenant   = var.ukcloud_mgmt_tenant
  l3_out   = [var.ukcloud_mgmt_l3_out]
  vrf      = var.ukcloud_mgmt_vrf
}

module "mgmt_cluster_host_overlay" {
  source = "./modules/epg-bd-config"

  epg_name          = "mgmt_cluster_host_overlay"
  vlan_tag          = "vlan-103"
  subnets           = var.mgmt_cluster_host_overlay_subnets
  access_generic_id = aci_access_generic.mgmt_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.mgmt.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = "uni/tn-mgmt"
  vrf      = "uni/tn-mgmt/ctx-inb"
}

module "client_avamar" {
  source = "./modules/epg-bd-config"

  epg_name          = "client_avamar"
  vlan_tag          = "vlan-155"
  subnets           = var.client_avamar_subnets
  access_generic_id = aci_access_generic.client_esx.id

  pod_id   = var.pod_id
  app_prof = aci_application_profile.avamar.id
  phys_dom = aci_physical_domain.vmware.id
  tenant   = var.protection_tenant
  l3_out   = [var.protection_l3_out]
  vrf      = var.protection_vrf
}

#########################
#### VMM Integration ####
#########################

resource "aci_vmm_domain" "vmware" {
  provider_profile_dn       = "uni/vmmp-VMware"
  name                      = "${var.pod_id}_ext_vmm"
  encap_mode                = "vlan"
  relation_infra_rs_vlan_ns = aci_vlan_pool.vmm_dynamic.id
}

resource "aci_vmm_controller" "vmware" {
  vmm_domain_dn             = aci_vmm_domain.vmware.id
  name                      = var.vmm_ci
  host_or_ip                = var.vmm_host
  root_cont_name            = var.pod_id
  stats_mode                = "enabled"
  relation_vmm_rs_mgmt_e_pg = module.mgmt_vmm.epg
  relation_vmm_rs_acc       = aci_vmm_credential.vmware.id
}

resource "aci_vmm_credential" "vmware" {
  vmm_domain_dn = aci_vmm_domain.vmware.id
  name          = var.vmm_ci
  usr           = var.vmm_svc_acc
}

resource "aci_vswitch_policy" "vmware" {
  vmm_domain_dn                                = aci_vmm_domain.vmware.id
  relation_vmm_rs_vswitch_override_cdp_if_pol  = var.cdp_enabled_policy
  relation_vmm_rs_vswitch_override_lldp_if_pol = var.lldp_disabled_policy
}
