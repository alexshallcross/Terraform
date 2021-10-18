#########################
#### Local Variables ####
#########################

locals {
  flattened_elevated_protection_ospf = flatten([
    for node_key, node in var.elevated_protection_ospf : [
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

resource "aci_vlan_pool" "elevated_protection" {
  name       = "vlan_static_elevated_protection"
  alloc_mode = "static"
}

resource "aci_ranges" "elevated_protection" {
  vlan_pool_dn = aci_vlan_pool.elevated_protection.id
  from         = "vlan-${var.elevated_protection_ospf_interface_vlan}"
  to           = "vlan-${var.elevated_protection_ospf_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_l3_domain_profile" "elevated_protection" {
  name                      = "elevated_protection"
  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_protection.id
}

resource "aci_attachable_access_entity_profile" "elevated_protection" {
  name = "elevated_protection"

  relation_infra_rs_dom_p = [
    aci_l3_domain_profile.elevated_protection.id
  ]
}

resource "aci_tenant" "elevated_protection" {
  name = "elevated_protection"
}

resource "aci_vrf" "elevated_protection" {
  tenant_dn = aci_tenant.elevated_protection.id
  name      = "elevated_protection"
}

resource "aci_ospf_interface_policy" "elevated_protection" {
  tenant_dn = aci_tenant.elevated_protection.id
  name      = "ospf_int_p2p_protocol_policy_elevated_protection"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "elevated_protection" {
  tenant_dn = aci_tenant.elevated_protection.id
  name      = "elevated_protection"

  relation_l3ext_rs_ectx       = aci_vrf.elevated_protection.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.elevated_protection.id
}

resource "aci_logical_node_profile" "elevated_protection" {
  l3_outside_dn = aci_l3_outside.elevated_protection.id
  name          = "elevated_protection"
}

resource "aci_logical_node_to_fabric_node" "elevated_protection" {
  for_each = var.elevated_protection_ospf

  logical_node_profile_dn = aci_logical_node_profile.elevated_protection.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "elevated_protection" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_protection.id
  name                    = "ospf_int_profile_elevated_protection"
}

resource "aci_l3out_ospf_interface_profile" "elevated_protection" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_protection.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.elevated_protection.id
}

resource "aci_l3out_path_attachment" "elevated_protection" {
  for_each = {
    for interface in local.flattened_elevated_protection_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.elevated_protection.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.elevated_protection_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "elevated_protection" {
  l3_outside_dn = aci_l3_outside.elevated_protection.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "elevated_protection_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_protection.id
  ip                                   = "0.0.0.0/0"

  scope = [
    "import-security",
    "export-rtctrl"
  ]
}

resource "aci_l3out_ospf_external_policy" "elevated_protection" {
  l3_outside_dn = aci_l3_outside.elevated_protection.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = var.elevated_protection_ospf_area_id
  area_type     = "regular"
}