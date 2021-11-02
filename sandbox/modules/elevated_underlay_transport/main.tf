#########################
#### Local Variables ####
#########################

locals {
  flattened_elevated_underlay_transport_ospf = flatten([
    for node_key, node in var.elevated_underlay_transport_ospf : [
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

resource "aci_vlan_pool" "elevated_cds" {
  name       = "vlan_static_elevated_cds"
  alloc_mode = "static"
}

resource "aci_physical_domain" "elevated_cds" {
  name = "elevated_cds"

  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_cds.id
}

resource "aci_attachable_access_entity_profile" "elevated_cds_l2" {
  name = "elevated_cds_l2"

  relation_infra_rs_dom_p = [
    aci_physical_domain.elevated_cds.id
  ]
}

resource "aci_leaf_access_bundle_policy_group" "elevated_cds_l2" {
  name  = "vpc_pol_grp_10G_lldp_lacp_elevated_underlay_transport"
  lag_t = "node"

  relation_infra_rs_h_if_pol    = var.interface_speed_policy
  relation_infra_rs_cdp_if_pol  = var.interface_cdp_policy
  relation_infra_rs_lldp_if_pol = var.interface_lldp_policy
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.elevated_cds_l2.id
}

resource "aci_leaf_interface_profile" "elevated_cds_l2" {
  name = "elevated_underlay_transport"
}

resource "aci_access_port_selector" "elevated_cds_l2" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.elevated_cds_l2.id
  name                           = "elevated_cds_l2"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_bundle_policy_group.elevated_cds_l2.id
}

resource "aci_access_port_block" "port_39" {
  access_port_selector_dn = aci_access_port_selector.elevated_cds_l2.id

  name      = "port_39"
  from_card = "1"
  from_port = "39"
  to_card   = "1"
  to_port   = "39"
}

resource "aci_access_port_block" "port_40" {
  access_port_selector_dn = aci_access_port_selector.elevated_cds_l2.id

  name      = "port_40"
  from_card = "1"
  from_port = "40"
  to_card   = "1"
  to_port   = "40"
}

resource "aci_leaf_profile" "elevated_cds_l2" {
  name = "elevated_cds_l2"

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.elevated_cds_l2.id
  ]
}

resource "aci_leaf_selector" "elevated_cds_l2" {
  leaf_profile_dn         = aci_leaf_profile.elevated_cds_l2.id
  name                    = "elevated_cds_l2"
  switch_association_type = "range"
}

resource "aci_node_block" "elevated_cds_l2_902" {
  switch_association_dn = aci_leaf_selector.elevated_cds_l2.id

  name  = "elevated_cds_l2_902"
  from_ = 902
  to_   = 902
}

resource "aci_node_block" "elevated_cds_l2_904" {
  switch_association_dn = aci_leaf_selector.elevated_cds_l2.id

  name  = "elevated_cds_l2_904"
  from_ = 904
  to_   = 904
}

resource "aci_vlan_pool" "elevated_underlay_transport" {
  name       = "vlan_static_elevated_underlay_transport"
  alloc_mode = "static"
}

resource "aci_ranges" "elevated_underlay_transport" {
  vlan_pool_dn = aci_vlan_pool.elevated_underlay_transport.id
  from         = "vlan-${var.elevated_underlay_transport_ospf_interface_vlan}"
  to           = "vlan-${var.elevated_underlay_transport_ospf_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_physical_domain" "elevated_underlay_transport" {
  name = "elevated_underlay_transport"

  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_underlay_transport.id
}

resource "aci_attachable_access_entity_profile" "elevated_underlay_transport" {
  name = "elevated_underlay_transport"

  relation_infra_rs_dom_p = [
    aci_physical_domain.elevated_underlay_transport.id,
    aci_l3_domain_profile.elevated_underlay_transport.id
  ]
}

resource "aci_l3_domain_profile" "elevated_underlay_transport" {
  name                      = "elevated_underlay_transport"
  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_underlay_transport.id
}

resource "aci_tenant" "elevated_underlay_transport" {
  name = "elevated_underlay_transport"
}

resource "aci_vrf" "elevated_underlay_transport" {
  tenant_dn = aci_tenant.elevated_underlay_transport.id
  name      = "elevated_underlay_transport"
}

resource "aci_ospf_interface_policy" "elevated_underlay_transport" {
  tenant_dn = aci_tenant.elevated_underlay_transport.id
  name      = "ospf_int_p2p_protocol_policy_elevated_underlay_transport"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "elevated_underlay_transport" {
  tenant_dn = aci_tenant.elevated_underlay_transport.id
  name      = "elevated_underlay_transport"

  relation_l3ext_rs_ectx       = aci_vrf.elevated_underlay_transport.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.elevated_underlay_transport.id
}

resource "aci_logical_node_profile" "elevated_underlay_transport" {
  l3_outside_dn = aci_l3_outside.elevated_underlay_transport.id
  name          = "elevated_underlay_transport"
}

resource "aci_logical_node_to_fabric_node" "elevated_underlay_transport" {
  for_each = var.elevated_underlay_transport_ospf

  logical_node_profile_dn = aci_logical_node_profile.elevated_underlay_transport.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "elevated_underlay_transport" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_underlay_transport.id
  name                    = "ospf_int_profile_elevated_underlay_transport"
}

resource "aci_l3out_ospf_interface_profile" "elevated_underlay_transport" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_underlay_transport.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.elevated_underlay_transport.id
}

resource "aci_l3out_path_attachment" "elevated_underlay_transport" {
  for_each = {
    for interface in local.flattened_elevated_underlay_transport_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.elevated_underlay_transport.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.elevated_underlay_transport_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "elevated_underlay_transport" {
  l3_outside_dn = aci_l3_outside.elevated_underlay_transport.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "elevated_underlay_transport_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_underlay_transport.id
  ip                                   = "0.0.0.0/0"
}

resource "aci_l3_ext_subnet" "elevated_underlay_transport_192_168_0_0" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_underlay_transport.id
  ip                                   = "192.168.0.0/16"

  scope = [
    "import-security",
    "shared-security"
  ]
}

resource "aci_l3_ext_subnet" "elevated_underlay_transport_10_0_0_0" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_underlay_transport.id
  ip                                   = "10.0.0.0/8"

  scope = [
    "import-security",
    "shared-security"
  ]
}

resource "aci_l3_ext_subnet" "elevated_underlay_transport_172_16_0_0" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_underlay_transport.id
  ip                                   = "172.16.0.0/12"

  scope = [
    "import-security",
    "shared-security"
  ]
}

resource "aci_l3out_ospf_external_policy" "elevated_underlay_transport" {
  l3_outside_dn = aci_l3_outside.elevated_underlay_transport.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = var.elevated_underlay_transport_ospf_area_id
  area_type     = "regular"
}