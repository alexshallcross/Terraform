#########################
#### Local Variables ####
#########################

locals {
  flattened_assured_protection_ospf = flatten([
    for node_key, node in var.assured_protection_ospf : [
      for interface in node.interfaces : {
        node_key     = node_key
        interface_id = interface.interface_id
        address      = interface.address
      }
    ]
  ])
}

#####################################################################
#### External Connectivity Build - Assured L2 Transport Underlay ####
#####################################################################

resource "aci_vlan_pool" "assured_protection" {
  name       = "vlan_static_assured_protection"
  alloc_mode = "static"
}

resource "aci_ranges" "assured_protection" {
  vlan_pool_dn = aci_vlan_pool.assured_protection.id
  from         = "vlan-${var.assured_protection_ospf_interface_vlan}"
  to           = "vlan-${var.assured_protection_ospf_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_l3_domain_profile" "assured_protection" {
  name                      = "assured_protection"
  relation_infra_rs_vlan_ns = aci_vlan_pool.assured_protection.id
}

resource "aci_attachable_access_entity_profile" "assured_protection" {
  name = "assured_protection"

  relation_infra_rs_dom_p = [
    aci_l3_domain_profile.assured_protection.id
  ]
}

resource "aci_tenant" "assured_protection" {
  name = "assured_protection"
}

resource "aci_vrf" "assured_protection" {
  tenant_dn = aci_tenant.assured_protection.id
  name      = "assured_protection"
}

resource "aci_ospf_interface_policy" "assured_protection" {
  tenant_dn = aci_tenant.assured_protection.id
  name      = "ospf_int_p2p_protocol_policy_assured_protection"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "assured_protection" {
  tenant_dn = aci_tenant.assured_protection.id
  name      = "assured_protection"

  relation_l3ext_rs_ectx       = aci_vrf.assured_protection.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.assured_protection.id
}

resource "aci_logical_node_profile" "assured_protection" {
  l3_outside_dn = aci_l3_outside.assured_protection.id
  name          = "assured_protection"
}

resource "aci_logical_node_to_fabric_node" "assured_protection" {
  for_each = var.assured_protection_ospf

  logical_node_profile_dn = aci_logical_node_profile.assured_protection.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "assured_protection" {
  logical_node_profile_dn = aci_logical_node_profile.assured_protection.id
  name                    = "ospf_int_profile_assured_protection"
}

resource "aci_l3out_ospf_interface_profile" "assured_protection" {
  logical_interface_profile_dn = aci_logical_interface_profile.assured_protection.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.assured_protection.id
}

resource "aci_l3out_path_attachment" "assured_protection" {
  for_each = {
    for interface in local.flattened_assured_protection_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.assured_protection.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.assured_protection_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "assured_protection" {
  l3_outside_dn = aci_l3_outside.assured_protection.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "assured_protection_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.assured_protection.id
  ip                                   = "0.0.0.0/0"

  scope = [
    "import-security",
    "export-rtctrl"
  ]
}

resource "aci_l3out_ospf_external_policy" "assured_protection" {
  l3_outside_dn = aci_l3_outside.assured_protection.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = var.assured_protection_ospf_area_id
  area_type     = "regular"
}

#######################
#### Output Values ####
#######################

output "tenant" {
  value = aci_tenant.assured_protection.id
}

output "vrf" {
  value = aci_vrf.assured_protection.id
}

output "l3out" {
  value = aci_l3_outside.assured_protection.id
}