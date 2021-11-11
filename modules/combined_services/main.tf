#########################
#### Local Variables ####
#########################

locals {
  flattened_assured_combined_services_bgp = flatten([
    for node_key, node in var.assured_combined_services_bgp : [
      for interface in node.interfaces : {
        node_key      = node_key
        interface_id  = interface.interface_id
        address       = interface.address
        bgp_peer      = interface.bgp_peer
        bgp_asn       = interface.bgp_asn
        bgp_local_asn = interface.bgp_local_asn
      }
    ]
  ])
  flattened_elevated_combined_services_bgp = flatten([
    for node_key, node in var.elevated_combined_services_bgp : [
      for interface in node.interfaces : {
        node_key      = node_key
        interface_id  = interface.interface_id
        address       = interface.address
        bgp_peer      = interface.bgp_peer
        bgp_asn       = interface.bgp_asn
        bgp_local_asn = interface.bgp_local_asn
      }
    ]
  ])
}

#####################################################################
#### External Connectivity Build - Assured L2 Transport Underlay ####
#####################################################################

resource "aci_vlan_pool" "assured_combined_services" {
  name       = "vlan_static_assured_combined_services"
  alloc_mode = "static"
}

resource "aci_ranges" "assured_combined_services" {
  vlan_pool_dn = aci_vlan_pool.assured_combined_services.id
  from         = "vlan-${var.assured_combined_services_bgp_interface_vlan}"
  to           = "vlan-${var.assured_combined_services_bgp_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_vlan_pool" "elevated_combined_services" {
  name       = "vlan_static_elevated_combined_services"
  alloc_mode = "static"
}

resource "aci_ranges" "elevated_combined_services" {
  vlan_pool_dn = aci_vlan_pool.elevated_combined_services.id
  from         = "vlan-${var.elevated_combined_services_bgp_interface_vlan}"
  to           = "vlan-${var.elevated_combined_services_bgp_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_l3_domain_profile" "assured_combined_services" {
  name                      = "assured_combined_services"
  relation_infra_rs_vlan_ns = aci_vlan_pool.assured_combined_services.id
}

resource "aci_l3_domain_profile" "elevated_combined_services" {
  name                      = "elevated_combined_services"
  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_combined_services.id
}

resource "aci_tenant" "combined_services" {
  name = "combined_services"
}

resource "aci_vrf" "combined_services" {
  tenant_dn = aci_tenant.combined_services.id
  name      = "combined_services"
}

######################
### Assured L3Out ###
######################

resource "aci_l3_outside" "assured_combined_services" {
  tenant_dn = aci_tenant.combined_services.id
  name      = "assured_combined_services"

  relation_l3ext_rs_ectx       = aci_vrf.combined_services.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.assured_combined_services.id
}

resource "aci_external_network_instance_profile" "assured_combined_services" {
  l3_outside_dn = aci_l3_outside.assured_combined_services.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "assured_combined_services_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.assured_combined_services.id
  ip                                   = "0.0.0.0/0"
}

resource "aci_logical_node_profile" "assured_combined_services" {
  l3_outside_dn = aci_l3_outside.assured_combined_services.id
  name          = "assured_combined_services"
}

resource "aci_logical_node_to_fabric_node" "assured_combined_services" {
  for_each = var.assured_combined_services_bgp

  logical_node_profile_dn = aci_logical_node_profile.assured_combined_services.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
  rtr_id_loop_back        = "no"
}

resource "aci_logical_interface_profile" "assured_combined_services" {
  logical_node_profile_dn = aci_logical_node_profile.assured_combined_services.id
  name                    = "bgp_int_profile_assured_combined_services"
}

resource "aci_l3out_path_attachment" "assured_combined_services" {
  for_each = {
    for interface in local.flattened_assured_combined_services_bgp : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.assured_combined_services.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.assured_combined_services_bgp_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_bgp_peer_connectivity_profile" "assured_combined_services" {
  for_each = {
    for interface in local.flattened_assured_combined_services_bgp : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_node_profile_dn = aci_l3out_path_attachment.assured_combined_services[each.key].id
  addr                    = each.value.bgp_peer
  peer_ctrl               = "bfd"
  as_number               = each.value.bgp_asn
  local_asn               = each.value.bgp_local_asn
  local_asn_propagate     = "replace-as"
}

######################
### Elevated L3Out ###
######################

resource "aci_l3_outside" "elevated_combined_services" {
  tenant_dn = aci_tenant.combined_services.id
  name      = "elevated_combined_services"

  relation_l3ext_rs_ectx       = aci_vrf.combined_services.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.elevated_combined_services.id
}

resource "aci_external_network_instance_profile" "elevated_combined_services" {
  l3_outside_dn = aci_l3_outside.elevated_combined_services.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "elevated_combined_services_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_combined_services.id
  ip                                   = "0.0.0.0/0"
}

resource "aci_logical_node_profile" "elevated_combined_services" {
  l3_outside_dn = aci_l3_outside.elevated_combined_services.id
  name          = "elevated_combined_services"
}

resource "aci_logical_node_to_fabric_node" "elevated_combined_services" {
  for_each = var.elevated_combined_services_bgp

  logical_node_profile_dn = aci_logical_node_profile.elevated_combined_services.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
  rtr_id_loop_back        = "no"
}

resource "aci_logical_interface_profile" "elevated_combined_services" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_combined_services.id
  name                    = "bgp_int_profile_elevated_combined_services"
}

resource "aci_l3out_path_attachment" "elevated_combined_services" {
  for_each = {
    for interface in local.flattened_elevated_combined_services_bgp : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.elevated_combined_services.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.elevated_combined_services_bgp_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_bgp_peer_connectivity_profile" "elevated_combined_services" {
  for_each = {
    for interface in local.flattened_elevated_combined_services_bgp : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_node_profile_dn = aci_l3out_path_attachment.elevated_combined_services[each.key].id
  addr                    = each.value.bgp_peer
  peer_ctrl               = "bfd"
  as_number               = each.value.bgp_asn
  local_asn               = each.value.bgp_local_asn
  local_asn_propagate     = "replace-as"
}