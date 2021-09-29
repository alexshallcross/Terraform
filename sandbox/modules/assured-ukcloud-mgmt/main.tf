#########################
#### Local Variables ####
#########################

locals {
  flattened_assured_ukcloud_mgmt_ospf = flatten([
    for node_key, node in var.assured_ukcloud_mgmt_ospf : [
      for interface in node.interfaces : {
        node_key     = node_key
        interface_id = interface.interface_id
        address      = interface.address
      }
    ]
  ])
}

####################################
#### Assured UKCloud Management ####
####################################

resource "aci_vlan_pool" "assured_ukcloud_mgmt" {
  name       = "vlan_static_l3_out_assured_ukcloud_mgmt"
  alloc_mode = "static"
}

resource "aci_ranges" "assured_ukcloud_mgmt" {
  vlan_pool_dn = aci_vlan_pool.assured_ukcloud_mgmt.id
  from         = "vlan-${var.assured_ukcloud_mgmt_ospf_interface_vlan}"
  to           = "vlan-${var.assured_ukcloud_mgmt_ospf_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_l3_domain_profile" "assured_ukcloud_mgmt" {
  name                      = "l3_out_assured_ukcloud_mgmt"
  relation_infra_rs_vlan_ns = aci_vlan_pool.assured_ukcloud_mgmt.id
}

resource "aci_tenant" "assured_ukcloud_mgmt" {
  name = "assured_ukcloud_mgmt"
}

resource "aci_vrf" "assured_ukcloud_mgmt" {
  tenant_dn = aci_tenant.assured_ukcloud_mgmt.id
  name      = "assured_ukcloud_mgmt"
}

resource "aci_ospf_interface_policy" "assured_ukcloud_mgmt" {
  tenant_dn = aci_tenant.assured_ukcloud_mgmt.id
  name      = "ospf_int_p2p_protocol_policy_assured_ukcloud_mgmt"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "assured_ukcloud_mgmt" {
  tenant_dn = aci_tenant.assured_ukcloud_mgmt.id
  name      = "assured_ukcloud_mgmt"

  relation_l3ext_rs_ectx       = aci_vrf.assured_ukcloud_mgmt.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.assured_ukcloud_mgmt.id
}

resource "aci_logical_node_profile" "assured_ukcloud_mgmt" {
  l3_outside_dn = aci_l3_outside.assured_ukcloud_mgmt.id
  name          = "assured_ukcloud_mgmt"
}

resource "aci_logical_node_to_fabric_node" "assured_ukcloud_mgmt" {
  for_each = var.assured_ukcloud_mgmt_ospf

  logical_node_profile_dn = aci_logical_node_profile.assured_ukcloud_mgmt.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "assured_ukcloud_mgmt" {
  logical_node_profile_dn = aci_logical_node_profile.assured_ukcloud_mgmt.id
  name                    = "ospf_int_profile_assured_ukcloud_mgmt"
}

resource "aci_l3out_ospf_interface_profile" "assured_ukcloud_mgmt" {
  logical_interface_profile_dn = aci_logical_interface_profile.assured_ukcloud_mgmt.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.assured_ukcloud_mgmt.id
}

resource "aci_l3out_path_attachment" "assured_ukcloud_mgmt" {
  for_each = {
    for interface in local.flattened_assured_ukcloud_mgmt_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.assured_ukcloud_mgmt.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.assured_ukcloud_mgmt_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "assured_ukcloud_mgmt" {
  l3_outside_dn = aci_l3_outside.assured_ukcloud_mgmt.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "assured_ukcloud_mgmt_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.assured_ukcloud_mgmt.id
  ip                                   = "0.0.0.0/0"
}

resource "aci_l3out_ospf_external_policy" "assured_ukcloud_mgmt" {
  l3_outside_dn = aci_l3_outside.assured_ukcloud_mgmt.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = var.assured_ukcloud_mgmt_ospf_area_id
  area_type     = "regular"
}