#########################
#### Local Variables ####
#########################

locals {
  flattened_elevated_external_ospf = flatten([
    for node_key, node in var.elevated_external_ospf : [
      for interface in node.interfaces : {
        node_key     = node_key
        interface_id = interface.interface_id
        address      = interface.address
      }
    ]
  ])
}

#########################################################
#### External Connectivity Build - Elevated External ####
#########################################################

resource "aci_vlan_pool" "elevated_external" {
  name       = "vlan_static_elevated_external"
  alloc_mode = "static"
}

resource "aci_ranges" "elevated_external" {
  vlan_pool_dn = aci_vlan_pool.elevated_external.id
  from         = "vlan-${var.elevated_external_ospf_interface_vlan}"
  to           = "vlan-${var.elevated_external_ospf_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_l3_domain_profile" "elevated_external" {
  name                      = "elevated_external"
  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_external.id
}

resource "aci_tenant" "elevated_external" {
  name = "elevated_external"
}

resource "aci_vrf" "elevated_external" {
  tenant_dn = aci_tenant.elevated_external.id
  name      = "elevated_external"
}

########################
#### Inbound Filter ####
########################

resource "aci_filter" "elevated_external_in" {
  tenant_dn = aci_tenant.elevated_external.id
  name      = "elevated_external_in"
}

/***
resource "aci_filter_entry" "elevated_external_in_ah" {
  filter_dn = aci_filter.elevated_external_in.id
  name      = "AH"
  ether_t   = "ip"
  prot      = "51"
}
***/

resource "aci_filter_entry" "elevated_external_in_https" {
  filter_dn   = aci_filter.elevated_external_in.id
  name        = "https"
  d_from_port = "https"
  d_to_port   = "https"
  ether_t     = "ip"
  prot        = "tcp"
}

/***
resource "aci_filter_entry" "elevated_external_in_esp" {
  filter_dn = aci_filter.elevated_external_in.id
  name      = "ESP"
  ether_t   = "ip"
  prot      = "50"
}
***/

resource "aci_filter_entry" "elevated_external_in_4500_udp" {
  filter_dn   = aci_filter.elevated_external_in.id
  name        = "4500_udp"
  d_from_port = "4500"
  d_to_port   = "4500"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_external_in_isakmp" {
  filter_dn   = aci_filter.elevated_external_in.id
  name        = "isakmp"
  d_from_port = "500"
  d_to_port   = "500"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_external_in_8443_tcp" {
  filter_dn   = aci_filter.elevated_external_in.id
  name        = "8443_tcp"
  d_from_port = "8443"
  d_to_port   = "8443"
  ether_t     = "ip"
  prot        = "tcp"
}

#########################
#### Outbound Filter ####
#########################

resource "aci_filter" "elevated_external_out" {
  tenant_dn = aci_tenant.elevated_external.id
  name      = "elevated_external_out"
}

/***
resource "aci_filter_entry" "elevated_external_out_ah" {
  filter_dn = aci_filter.elevated_external_out.id
  name      = "AH"
  ether_t   = "ip"
  prot      = "51"
}
***/

resource "aci_filter_entry" "elevated_external_out_https" {
  filter_dn   = aci_filter.elevated_external_out.id
  name        = "https"
  d_from_port = "https"
  d_to_port   = "https"
  ether_t     = "ip"
  prot        = "tcp"
}


/***
resource "aci_filter_entry" "elevated_external_out_esp" {
  filter_dn = aci_filter.elevated_external_out.id
  name      = "ESP"
  ether_t   = "ip"
  prot      = "50"
}
***/

resource "aci_filter_entry" "elevated_external_out_4500_udp" {
  filter_dn   = aci_filter.elevated_external_out.id
  name        = "4500_udp"
  d_from_port = "4500"
  d_to_port   = "4500"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_external_out_isakmp" {
  filter_dn   = aci_filter.elevated_external_out.id
  name        = "isakmp"
  d_from_port = "500"
  d_to_port   = "500"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_external_out_8443_tcp" {
  filter_dn   = aci_filter.elevated_external_out.id
  name        = "8443_tcp"
  d_from_port = "8443"
  d_to_port   = "8443"
  ether_t     = "ip"
  prot        = "tcp"
}

##########################
#### Inbound Contract ####
##########################

resource "aci_contract" "elevated_external_in" {
  tenant_dn = aci_tenant.elevated_external.id
  name      = "elevated_external_in"
  scope     = "tenant"
}

resource "aci_contract_subject" "elevated_external_in" {
  contract_dn = aci_contract.elevated_external_in.id
  name        = "elevated_external_in"
  relation_vz_rs_subj_filt_att = [
    aci_filter.elevated_external_in.id
  ]
}

###########################
#### Outbound Contract ####
###########################

resource "aci_contract" "elevated_external_out" {
  tenant_dn = aci_tenant.elevated_external.id
  name      = "elevated_external_out"
  scope     = "tenant"
}

resource "aci_contract_subject" "elevated_external_out" {
  contract_dn = aci_contract.elevated_external_out.id
  name        = "elevated_external_out"
  relation_vz_rs_subj_filt_att = [
    aci_filter.elevated_external_out.id
  ]
}

###############################
#### OSPF Interface Policy ####
###############################

resource "aci_ospf_interface_policy" "elevated_external" {
  tenant_dn = aci_tenant.elevated_external.id
  name      = "ospf_int_p2p_protocol_policy_elevated_external"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "elevated_external" {
  tenant_dn = aci_tenant.elevated_external.id
  name      = "elevated_external"

  relation_l3ext_rs_ectx       = aci_vrf.elevated_external.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.elevated_external.id
}

resource "aci_logical_node_profile" "elevated_external" {
  l3_outside_dn = aci_l3_outside.elevated_external.id
  name          = "elevated_external"
}

resource "aci_logical_node_to_fabric_node" "elevated_external" {
  for_each = var.elevated_external_ospf

  logical_node_profile_dn = aci_logical_node_profile.elevated_external.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "elevated_external" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_external.id
  name                    = "ospf_int_profile_elevated_external"
}

resource "aci_l3out_ospf_interface_profile" "elevated_external" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_external.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.elevated_external.id
}

resource "aci_l3out_path_attachment" "elevated_external" {
  for_each = {
    for interface in local.flattened_elevated_external_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.elevated_external.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.elevated_external_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "elevated_external" {
  l3_outside_dn = aci_l3_outside.elevated_external.id
  name          = "all"

  relation_fv_rs_prov = [
    aci_contract_subject.elevated_external_out.id
  ]
  relation_fv_rs_cons = [
    aci_contract_subject.elevated_external_in.id
  ]
}

resource "aci_l3_ext_subnet" "elevated_external_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_external.id
  ip                                   = "0.0.0.0/0"

  scope = [
    "import-security",
    "export-rtctrl"
  ]
}

resource "aci_l3out_ospf_external_policy" "elevated_external" {
  l3_outside_dn = aci_l3_outside.elevated_external.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = var.elevated_external_ospf_area_id
  area_type     = "regular"
}

#######################
#### Output Values ####
#######################

output "aci_elevated_external_aep_domain" {
  value = aci_l3_domain_profile.elevated_external.id
}