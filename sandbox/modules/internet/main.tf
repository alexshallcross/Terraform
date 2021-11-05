#########################
#### Local Variables ####
#########################

locals {
  flattened_internet_ospf = flatten([
    for node_key, node in var.internet_ospf : [
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

# Creating the VLAN Pool

resource "aci_vlan_pool" "internet" {
  name       = "vlan_static_internet"
  alloc_mode = "static"
}

resource "aci_ranges" "internet" {
  vlan_pool_dn = aci_vlan_pool.internet.id
  from         = "vlan-${var.internet_ospf_interface_vlan}"
  to           = "vlan-${var.internet_ospf_interface_vlan}"
  alloc_mode   = "static"
}

# Creating the External Routed Domain

resource "aci_l3_domain_profile" "internet" {
  name                      = "internet"
  relation_infra_rs_vlan_ns = aci_vlan_pool.internet.id
}

# Create the AEP

resource "aci_attachable_access_entity_profile" "internet" {
  name                    = "internet"
  relation_infra_rs_dom_p = [
    aci_l3_domain_profile.internet.id
  ]
}

# Create Interface Policy Group

resource "aci_leaf_access_port_policy_group" "internet" {
  name = "internet"

  relation_infra_rs_h_if_pol    = var.interface_speed_policy
  relation_infra_rs_cdp_if_pol  = var.interface_cdp_policy
  relation_infra_rs_lldp_if_pol = var.interface_lldp_policy
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.internet.id
}

# Create Interface Profile

resource "aci_leaf_interface_profile" "internet" {
  name = "internet"
}

resource "aci_access_port_selector" "internet" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.internet.id
  name                           = "internet"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.internet.id
}

resource "aci_access_port_block" "port_1" {
  access_port_selector_dn = aci_access_port_selector.internet.id
  name                    = "port_1"
  from_card               = "1"
  from_port               = "1"
  to_card                 = "1"
  to_port                 = "1"
}

resource "aci_access_port_block" "port_2" {
  access_port_selector_dn = aci_access_port_selector.internet.id
  name                    = "port_2"
  from_card               = "1"
  from_port               = "2"
  to_card                 = "1"
  to_port                 = "2"
}

# Create a Switch Policy Profile (Switch Selector)

resource "aci_leaf_profile" "internet" {
  name = "internet"

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.internet.id
  ]
}

resource "aci_leaf_selector" "internet" {
  leaf_profile_dn         = aci_leaf_profile.internet.id
  name                    = "internet"
  switch_association_type = "range"
}

resource "aci_node_block" "internet" {
  switch_association_dn = aci_leaf_selector.internet.id
  name                  = "internet"
  from_                 = min(keys(var.internet_ospf)...)
  to_                   = max(keys(var.internet_ospf)...)
}

# Create tenant
resource "aci_tenant" "internet" {
  name = "internet"
}

resource "aci_vrf" "internet" {
  tenant_dn = aci_tenant.internet.id
  name      = "internet"
}

resource "aci_ospf_interface_policy" "internet" {
  tenant_dn = aci_tenant.internet.id
  name      = "ospf_int_p2p_protocol_policy_internet"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "internet" {
  tenant_dn = aci_tenant.internet.id
  name      = "internet"

  relation_l3ext_rs_ectx       = aci_vrf.internet.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.internet.id
}

resource "aci_logical_node_profile" "internet" {
  l3_outside_dn = aci_l3_outside.internet.id
  name          = "internet"
}

resource "aci_logical_node_to_fabric_node" "internet" {
  for_each = var.internet_ospf

  logical_node_profile_dn = aci_logical_node_profile.internet.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "internet" {
  logical_node_profile_dn = aci_logical_node_profile.internet.id
  name                    = "ospf_int_profile_internet"
}

resource "aci_l3out_ospf_interface_profile" "internet" {
  logical_interface_profile_dn = aci_logical_interface_profile.internet.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.internet.id
}

resource "aci_l3out_path_attachment" "internet" {
  for_each = {
    for interface in local.flattened_internet_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.internet.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.internet_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "internet" {
  l3_outside_dn = aci_l3_outside.internet.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "internet_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.internet.id
  ip                                   = "0.0.0.0/0"

  scope = [
    "import-security",
    "export-rtctrl"
  ]
}

resource "aci_l3out_ospf_external_policy" "internet" {
  l3_outside_dn = aci_l3_outside.internet.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = var.internet_ospf_area_id
  area_type     = "regular"
}

#######################
#### Output Values ####
#######################

output "aci_internet_interface_profile" {
  value = aci_leaf_interface_profile.internet.id
}

output "tenant" {
  value = aci_tenant.internet.id
}

output "vrf" {
  value = aci_vrf.internet.id
}

output "l3out" {
  value = aci_l3_outside.internet.id
}