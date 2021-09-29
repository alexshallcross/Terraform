#########################
#### Local Variables ####
#########################

locals {
  flattened_assured_underlay_transport_ospf = flatten([
    for node_key, node in var.assured_underlay_transport_ospf : [
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

resource "aci_vlan_pool" "assured_cds" {
  name       = "vlan_static_assured_cds"
  alloc_mode = "static"
}

resource "aci_physical_domain" "assured_cds" {
  name = "assured_cds"

  relation_infra_rs_vlan_ns = aci_vlan_pool.assured_cds.id
}

resource "aci_attachable_access_entity_profile" "assured_cds_l2" {
  name = "assured_cds_l2"

  relation_infra_rs_dom_p = [
    aci_physical_domain.assured_cds.id
  ]
}

resource "aci_leaf_access_bundle_policy_group" "assured_cds_l2" {
  name        = "vpc_pol_grp_10G_lldp_lacp_assured_underlay_transport"
  lag_t       = "node"

  relation_infra_rs_h_if_pol    = var.interface_speed_policy
  relation_infra_rs_cdp_if_pol  = var.interface_cdp_policy
  relation_infra_rs_lldp_if_pol = var.interface_lldp_policy
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.assured_cds_l2.id
}

resource "aci_leaf_interface_profile" "assured_cds_l2" {
  name = "assured_underlay_transport"
}

resource "aci_access_port_selector" "assured_cds_l2" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.assured_cds_l2.id
  name                           = "assured_cds_l2"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_bundle_policy_group.assured_cds_l2.id
}

resource "aci_access_port_block" "port_23" {
  access_port_selector_dn = aci_access_port_selector.assured_cds_l2.id
  
  name      = "port_23"
  from_card = "1"
  from_port = "23"
  to_card   = "1"
  to_port   = "23"
}

resource "aci_access_port_block" "port_24" {
  access_port_selector_dn = aci_access_port_selector.assured_cds_l2.id

  name      = "port_24"
  from_card = "1"
  from_port = "24"
  to_card   = "1"
  to_port   = "24"
}

resource "aci_leaf_profile" "assured_cds_l2" {
  name = "assured_cds_l2"

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.assured_cds_l2.id
  ]
}

resource "aci_leaf_selector" "assured_cds_l2" {
  leaf_profile_dn         = aci_leaf_profile.assured_cds_l2.id
  name                    = "assured_cds_l2"
  switch_association_type = "range"
}

resource "aci_node_block" "assured_cds_l2_901" {
  switch_association_dn = aci_leaf_selector.assured_cds_l2.id

  name  = "assured_cds_l2_901"
  from_ = 901
  to_   = 901
}

resource "aci_node_block" "assured_cds_l2_903" {
  switch_association_dn = aci_leaf_selector.assured_cds_l2.id

  name  = "assured_cds_l2_903"
  from_ = 903
  to_   = 903
}

resource "aci_vlan_pool" "assured_underlay_transport" {
  name       = "vlan_static_assured_underlay_transport"
  alloc_mode = "static"
}

resource "aci_ranges" "assured_underlay_transport" {
  vlan_pool_dn = aci_vlan_pool.assured_underlay_transport.id
  from         = "vlan-${var.assured_underlay_transport_ospf_interface_vlan}"
  to           = "vlan-${var.assured_underlay_transport_ospf_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_physical_domain" "assured_underlay_transport" {
  name = "assured_underlay_transport"

  relation_infra_rs_vlan_ns = aci_vlan_pool.assured_underlay_transport.id
}

resource "aci_attachable_access_entity_profile" "assured_underlay_transport" {
  name = "assured_underlay_transport"

  relation_infra_rs_dom_p = [
    aci_physical_domain.assured_underlay_transport.id,
    aci_l3_domain_profile.assured_underlay_transport.id
  ]
}

resource "aci_l3_domain_profile" "assured_underlay_transport" {
  name                      = "assured_underlay_transport"
  relation_infra_rs_vlan_ns = aci_vlan_pool.assured_underlay_transport.id
}

resource "aci_tenant" "assured_underlay_transport" {
  name = "assured_underlay_transport"
}

resource "aci_vrf" "assured_underlay_transport" {
  tenant_dn = aci_tenant.assured_underlay_transport.id
  name      = "assured_underlay_transport"
}

resource "aci_ospf_interface_policy" "assured_underlay_transport" {
  tenant_dn = aci_tenant.assured_underlay_transport.id
  name      = "ospf_int_p2p_protocol_policy_assured_underlay_transport"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "assured_underlay_transport" {
  tenant_dn = aci_tenant.assured_underlay_transport.id
  name      = "assured_underlay_transport"

  relation_l3ext_rs_ectx = aci_vrf.assured_underlay_transport.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.assured_underlay_transport.id
}

resource "aci_logical_node_profile" "assured_underlay_transport" {
  l3_outside_dn = aci_l3_outside.assured_underlay_transport.id
  name          = "assured_underlay_transport"
}

resource "aci_logical_node_to_fabric_node" "assured_underlay_transport" {
  for_each = var.assured_underlay_transport_ospf

  logical_node_profile_dn = aci_logical_node_profile.assured_underlay_transport.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "assured_underlay_transport" {
  logical_node_profile_dn = aci_logical_node_profile.assured_underlay_transport.id
  name                    = "ospf_int_profile_assured_underlay_transport"
}

resource "aci_l3out_ospf_interface_profile" "assured_underlay_transport" {
  logical_interface_profile_dn = aci_logical_interface_profile.assured_underlay_transport.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.assured_underlay_transport.id
}

resource "aci_l3out_path_attachment" "assured_underlay_transport" {
  for_each = {
    for interface in local.flattened_assured_underlay_transport_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.assured_underlay_transport.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.assured_underlay_transport_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "assured_underlay_transport" {
  l3_outside_dn = aci_l3_outside.assured_underlay_transport.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "assured_underlay_transport_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.assured_underlay_transport.id
  ip                                   = "0.0.0.0/0"
}

resource "aci_l3_ext_subnet" "assured_underlay_transport_192_168_0_0" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.assured_underlay_transport.id
  ip                                   = "192.168.0.0/16"
  
  scope = [
    "import-security",
    "shared-security"
   ] 
}

resource "aci_l3_ext_subnet" "assured_underlay_transport_10_0_0_0" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.assured_underlay_transport.id
  ip                                   = "10.0.0.0/8"
  
  scope = [
    "import-security",
    "shared-security"
   ] 
}

resource "aci_l3_ext_subnet" "assured_underlay_transport_172_16_0_0" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.assured_underlay_transport.id
  ip                                   = "172.16.0.0/12"
  
  scope = [
    "import-security",
    "shared-security"
   ] 
}

resource "aci_l3out_ospf_external_policy" "assured_underlay_transport" {
  l3_outside_dn = aci_l3_outside.assured_underlay_transport.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = "${var.assured_underlay_transport_ospf_area_id}"
  area_type     = "regular"
}