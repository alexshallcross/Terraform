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



##############
#### EPGs ####
##############
/***
For each EPG the 'relation_fv_rs_graph_def' attribute should be ignored as Terraform 
will write a null value to it, which will then be immediately overwritten by the APIC 
to a different value, resulting in a change showing each time a run is planned.
***/

# Creates the "podxxxxx_cimc" EPG
resource "aci_application_epg" "cimc" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_cimc"])
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

# Links the "podxxxxx_cimc" EPG to a physical domain
resource "aci_epg_to_domain" "cimc_mgmt" {
  application_epg_dn = aci_application_epg.cimc.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_cimc" EPG and VLAN tag to the CIMC AEP
resource "aci_epgs_using_function" "cimc" {
  access_generic_dn = aci_access_generic.cimc.id
  tdn               = aci_application_epg.cimc.id
  encap             = "vlan-100"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_storage_mgmt" EPG
resource "aci_application_epg" "storage_mgmt" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_storage_mgmt"])
  relation_fv_rs_bd      = aci_bridge_domain.storage_mgmt.id
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

# Links the "podxxxxx_storage_mgmt" EPG to a physical domain
resource "aci_epg_to_domain" "storage_mgmt" {
  application_epg_dn = aci_application_epg.storage_mgmt.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_storage_mgmt" EPG and VLAN tag to the CIMC AEP
resource "aci_epgs_using_function" "storage_mgmt" {
  access_generic_dn = aci_access_generic.cimc.id
  tdn               = aci_application_epg.storage_mgmt.id
  encap             = "vlan-118"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_mgmt_cluster_vmware" EPG
resource "aci_application_epg" "mgmt_cluster_vmware" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_mgmt"])
  relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_vmware.id
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

# Links the "podxxxxx_mgmt_cluster_vmware" EPG to a physical domain
resource "aci_epg_to_domain" "mgmt_cluster_vmware" {
  application_epg_dn = aci_application_epg.mgmt_cluster_vmware.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_mgmt_cluster_vmware" EPG and VLAN tag to the MGMT ESX AEP
resource "aci_epgs_using_function" "mgmt_cluster_vmware" {
  access_generic_dn = aci_access_generic.mgmt_esx.id
  tdn               = aci_application_epg.mgmt_cluster_vmware.id
  encap             = "vlan-101"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_mgmt_cluster_tools" EPG
resource "aci_application_epg" "mgmt_cluster_tools" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_mgmt_cluster_tools"])
  relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_tools.id
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

# Links the "podxxxxx_mgmt_cluster_tools" EPG to a physical domain
resource "aci_epg_to_domain" "mgmt_cluster_tools" {
  application_epg_dn = aci_application_epg.mgmt_cluster_tools.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_mgmt_cluster_tools" EPG and VLAN tag to the MGMT ESX AEP
resource "aci_epgs_using_function" "mgmt_cluster_tools" {
  access_generic_dn = aci_access_generic.mgmt_esx.id
  tdn               = aci_application_epg.mgmt_cluster_tools.id
  encap             = "vlan-102"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_mgmt_cluster_vmotion" EPG
resource "aci_application_epg" "mgmt_cluster_vmotion" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_mgmt_cluster_vmotion"])
  relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_vmotion.id
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

# Links the "podxxxxx_mgmt_cluster_vmotion" EPG to a physical domain
resource "aci_epg_to_domain" "mgmt_cluster_vmotion" {
  application_epg_dn = aci_application_epg.mgmt_cluster_vmotion.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_mgmt_cluster_vmotion" EPG and VLAN tag to the MGMT ESX AEP
resource "aci_epgs_using_function" "mgmt_cluster_vmotion" {
  access_generic_dn = aci_access_generic.mgmt_esx.id
  tdn               = aci_application_epg.mgmt_cluster_vmotion.id
  encap             = "vlan-104"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_client_cluster_1_vmware" EPG
resource "aci_application_epg" "client_cluster_1_vmware" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_client_cluster_1_vmware"])
  relation_fv_rs_bd      = aci_bridge_domain.client_cluster_1_vmware.id
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

# Links the "podxxxxx_client_cluster_1_vmware" EPG to a physical domain
resource "aci_epg_to_domain" "client_cluster_1_vmware" {
  application_epg_dn = aci_application_epg.client_cluster_1_vmware.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_client_cluster_1_vmware" EPG and VLAN tag to the Client ESX AEP
resource "aci_epgs_using_function" "client_cluster_1_vmware" {
  access_generic_dn = aci_access_generic.client_esx.id
  tdn               = aci_application_epg.client_cluster_1_vmware.id
  encap             = "vlan-110"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_client_cluster_1_vmotion" EPG
resource "aci_application_epg" "client_cluster_1_vmotion" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_client_cluster_1_vmotion"])
  relation_fv_rs_bd      = aci_bridge_domain.client_cluster_1_vmotion.id
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

# Links the "podxxxxx_client_cluster_1_vmotion" EPG to a physical domain
resource "aci_epg_to_domain" "client_cluster_1_vmotion" {
  application_epg_dn = aci_application_epg.client_cluster_1_vmotion.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_client_cluster_1_vmotion" EPG and VLAN tag to the Client ESX AEP
resource "aci_epgs_using_function" "client_cluster_1_vmotion" {
  access_generic_dn = aci_access_generic.client_esx.id
  tdn               = aci_application_epg.client_cluster_1_vmotion.id
  encap             = "vlan-111"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_client_cluster_1_vxlan" EPG
resource "aci_application_epg" "client_cluster_1_vxlan" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_client_cluster_1_vxlan"])
  relation_fv_rs_bd      = aci_bridge_domain.client_cluster_1_vxlan.id
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

# Links the "podxxxxx_client_cluster_1_vxlan" EPG to a physical domain
resource "aci_epg_to_domain" "client_cluster_1_vxlan" {
  application_epg_dn = aci_application_epg.client_cluster_1_vxlan.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_client_cluster_1_vxlan" EPG and VLAN tag to the Client ESX AEP
resource "aci_epgs_using_function" "client_cluster_1_vxlan" {
  access_generic_dn = aci_access_generic.client_esx.id
  tdn               = aci_application_epg.client_cluster_1_vxlan.id
  encap             = "vlan-115"
  instr_imedcy      = "immediate"
  mode              = "regular"
}

# Creates the "podxxxxx_mgmt_cluster_avamar" EPG
resource "aci_application_epg" "mgmt_cluster_avamar" {
  application_profile_dn = aci_application_profile.vmware.id
  name                   = join("", [var.pod_id, "_mgmt_cluster_avamar"])
  relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_avamar.id
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

# Links the "podxxxxx_mgmt_cluster_avamar" EPG to a physical domain
resource "aci_epg_to_domain" "mgmt_cluster_avamar" {
  application_epg_dn = aci_application_epg.mgmt_cluster_avamar.id
  tdn                = aci_physical_domain.vmware.id
}

# Links the "podxxxxx_mgmt_cluster_avamar" EPG and VLAN tag to the Client ESX AEP
resource "aci_epgs_using_function" "mgmt_cluster_avamar" {
  access_generic_dn = aci_access_generic.client_esx.id
  tdn               = aci_application_epg.mgmt_cluster_avamar.id
  encap             = "vlan-156"
  instr_imedcy      = "immediate"
  mode              = "regular"
}



########################
#### Bridge Domains ####
########################

# Creates the "podxxxxx_cimc" bridge domain
resource "aci_bridge_domain" "cimc" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_cimc"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_cimc" bridge domain
resource "aci_subnet" "cimc" {
  for_each = toset(var.cimc_subnets)

  parent_dn = aci_bridge_domain.cimc.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_storage_mgmt" bridge domain
resource "aci_bridge_domain" "storage_mgmt" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_storage_mgmt"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_storage_mgmt" bridge domain
resource "aci_subnet" "storage_mgmt" {
  for_each = toset(var.storage_mgmt_subnets)

  parent_dn = aci_bridge_domain.storage_mgmt.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_mgmt_cluster_vmware" bridge domain
resource "aci_bridge_domain" "mgmt_cluster_vmware" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_mgmt_cluster_vmware"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_mgmt_cluster_vmware" bridge domain
resource "aci_subnet" "mgmt" {
  for_each = toset(var.mgmt_cluster_vmware_subnets)

  parent_dn = aci_bridge_domain.mgmt_cluster_vmware.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_mgmt_cluster_tools" bridge domain
resource "aci_bridge_domain" "mgmt_cluster_tools" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_mgmt_cluster_tools"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_mgmt_cluster_tools" bridge domain
resource "aci_subnet" "mgmt_cluster_tools" {
  for_each = toset(var.mgmt_cluster_tools_subnets)

  parent_dn = aci_bridge_domain.mgmt_cluster_tools.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_mgmt_cluster_vmotion" bridge domain
resource "aci_bridge_domain" "mgmt_cluster_vmotion" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_mgmt_cluster_vmotion"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_mgmt_cluster_vmotion" bridge domain
resource "aci_subnet" "mgmt_cluster_vmotion" {
  for_each = toset(var.mgmt_cluster_vmotion_subnets)

  parent_dn = aci_bridge_domain.mgmt_cluster_vmotion.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_mgmt_cluster_avamar" bridge domain
resource "aci_bridge_domain" "mgmt_cluster_avamar" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_mgmt_cluster_avamar"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_mgmt_cluster_avamar" bridge domain
resource "aci_subnet" "mgmt_cluster_avamar" {
  for_each = toset(var.mgmt_cluster_avamar_subnets)

  parent_dn = aci_bridge_domain.mgmt_cluster_avamar.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_client_cluster_1_vmware" bridge domain
resource "aci_bridge_domain" "client_cluster_1_vmware" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_client_cluster_1_vmware"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_client_cluster_1_vmware" bridge domain
resource "aci_subnet" "client_cluster_1_vmware" {
  for_each = toset(var.client_cluster_1_vmware_subnets)

  parent_dn = aci_bridge_domain.client_cluster_1_vmware.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_client_cluster_1_vmotion" bridge domain
resource "aci_bridge_domain" "client_cluster_1_vmotion" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_client_cluster_1_vmotion"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_client_cluster_1_vmotion" bridge domain
resource "aci_subnet" "client_cluster_1_vmotion" {
  for_each = toset(var.client_cluster_1_vmotion_subnets)

  parent_dn = aci_bridge_domain.client_cluster_1_vmotion.id
  ip        = each.value
  scope = [
    "public"
  ]
}

# Creates the "podxxxxx_client_cluster_1_vxlan" bridge domain
resource "aci_bridge_domain" "client_cluster_1_vxlan" {
  tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
  name                = join("", [var.pod_id, "_client_cluster_1_vxlan"])
  ep_move_detect_mode = "garp"
  relation_fv_rs_bd_to_out = [
    data.aci_l3_outside.ukcloud_mgmt.id
  ]
  relation_fv_rs_ctx = data.aci_vrf.ukcloud_mgmt.id
}

# Creates a subnet for the "podxxxxx_client_cluster_1_vxlan" bridge domain
resource "aci_subnet" "client_cluster_1_vxlan" {
  for_each = toset(var.client_cluster_1_vxlan_subnets)

  parent_dn = aci_bridge_domain.client_cluster_1_vxlan.id
  ip        = each.value
  scope = [
    "public"
  ]
}