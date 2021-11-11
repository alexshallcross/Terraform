#########################
#### Local Variables ####
#########################

locals {
  flattened_elevated_psn_ospf = flatten([
    for node_key, node in var.elevated_psn_ospf : [
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

resource "aci_vlan_pool" "elevated_psn" {
  name       = "vlan_static_elevated_psn"
  alloc_mode = "static"
}

resource "aci_ranges" "elevated_psn" {
  vlan_pool_dn = aci_vlan_pool.elevated_psn.id
  from         = "vlan-${var.elevated_psn_ospf_interface_vlan}"
  to           = "vlan-${var.elevated_psn_ospf_interface_vlan}"
  alloc_mode   = "static"
}

resource "aci_l3_domain_profile" "elevated_psn" {
  name                      = "elevated_psn"
  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_psn.id
}

resource "aci_tenant" "elevated_psn" {
  name = "elevated_psn"
}

resource "aci_vrf" "elevated_psn" {
  tenant_dn = aci_tenant.elevated_psn.id
  name      = "elevated_psn"
}

resource "aci_ospf_interface_policy" "elevated_psn" {
  tenant_dn = aci_tenant.elevated_psn.id
  name      = "ospf_int_p2p_protocol_policy_elevated_psn"
  ctrl = [
    "advert-subnet",
    "bfd",
    "mtu-ignore"
  ]
  nw_t = "p2p"
}

resource "aci_l3_outside" "elevated_psn" {
  tenant_dn = aci_tenant.elevated_psn.id
  name      = "elevated_psn"

  relation_l3ext_rs_ectx       = aci_vrf.elevated_psn.id
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.elevated_psn.id
}

resource "aci_logical_node_profile" "elevated_psn" {
  l3_outside_dn = aci_l3_outside.elevated_psn.id
  name          = "elevated_psn"
}

resource "aci_logical_node_to_fabric_node" "elevated_psn" {
  for_each = var.elevated_psn_ospf

  logical_node_profile_dn = aci_logical_node_profile.elevated_psn.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "elevated_psn" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_psn.id
  name                    = "ospf_int_profile_elevated_psn"
}

resource "aci_l3out_ospf_interface_profile" "elevated_psn" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_psn.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.elevated_psn.id
}

resource "aci_l3out_path_attachment" "elevated_psn" {
  for_each = {
    for interface in local.flattened_elevated_psn_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.elevated_psn.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.elevated_psn_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "elevated_psn" {
  l3_outside_dn = aci_l3_outside.elevated_psn.id
  name          = "all"

  relation_fv_rs_prov = [
    aci_contract_subject.elevated_psn_out.id
  ]
  relation_fv_rs_cons = [
    aci_contract_subject.elevated_psn_in.id
  ]
}

resource "aci_l3_ext_subnet" "elevated_psn_all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_psn.id
  ip                                   = "0.0.0.0/0"

  scope = [
    "import-security",
    "export-rtctrl"
  ]
}

resource "aci_l3out_ospf_external_policy" "elevated_psn" {
  l3_outside_dn = aci_l3_outside.elevated_psn.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = var.elevated_psn_ospf_area_id
  area_type     = "regular"
}

########################
#### Inbound Filter ####
########################

resource "aci_filter" "elevated_psn_in" {
  tenant_dn = aci_tenant.elevated_psn.id
  name      = "elevated_psn_in"
}

/***
resource "aci_filter_entry" "elevated_psn_in_ah" {
  filter_dn = aci_filter.elevated_psn_in.id
  name      = "AH"
  ether_t   = "ip"
  prot      = "51"
}
***/

resource "aci_filter_entry" "elevated_psn_in_icmp_uncreachable" {
  filter_dn = aci_filter.elevated_psn_in.id
  name      = "icmp_uncreachable"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "dst-unreach"
}

resource "aci_filter_entry" "elevated_psn_in_https" {
  filter_dn   = aci_filter.elevated_psn_in.id
  name        = "https"
  d_from_port = "https"
  d_to_port   = "https"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "elevated_psn_in_icmp_echo_reply" {
  filter_dn = aci_filter.elevated_psn_in.id
  name      = "icmp_echo_reply"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "echo-rep"
}

/***
resource "aci_filter_entry" "elevated_psn_in_esp" {
  filter_dn = aci_filter.elevated_psn_in.id
  name      = "ESP"
  ether_t   = "ip"
  prot      = "50"
}
***/

resource "aci_filter_entry" "elevated_psn_in_4500_udp" {
  filter_dn   = aci_filter.elevated_psn_in.id
  name        = "4500_udp"
  d_from_port = "4500"
  d_to_port   = "4500"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_psn_in_smtp" {
  filter_dn   = aci_filter.elevated_psn_in.id
  name        = "smtp"
  d_from_port = "smtp"
  d_to_port   = "smtp"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "elevated_psn_in_icmp_echo" {
  filter_dn = aci_filter.elevated_psn_in.id
  name      = "icmp_echo"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "echo"
}

resource "aci_filter_entry" "elevated_psn_in_http" {
  filter_dn   = aci_filter.elevated_psn_in.id
  name        = "http"
  d_from_port = "http"
  d_to_port   = "http"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "elevated_psn_in_icmp_time_exceeded" {
  filter_dn = aci_filter.elevated_psn_in.id
  name      = "icmp_time_exceeded"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "time-exceeded"
}

resource "aci_filter_entry" "elevated_psn_in_isakmp" {
  filter_dn   = aci_filter.elevated_psn_in.id
  name        = "isakmp"
  d_from_port = "500"
  d_to_port   = "500"
  ether_t     = "ip"
  prot        = "udp"
}

#########################
#### Outbound Filter ####
#########################

resource "aci_filter" "elevated_psn_out" {
  tenant_dn = aci_tenant.elevated_psn.id
  name      = "elevated_psn_out"
}

resource "aci_filter_entry" "elevated_psn_out_http" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "http"
  d_from_port = "http"
  d_to_port   = "http"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "elevated_psn_out_isakmp" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "isakmp"
  d_from_port = "500"
  d_to_port   = "500"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_psn_out_icmp_echo" {
  filter_dn = aci_filter.elevated_psn_out.id
  name      = "icmp_echo"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "echo"
}

resource "aci_filter_entry" "elevated_psn_out_dns" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "dns"
  d_from_port = "dns"
  d_to_port   = "dns"
  ether_t     = "ip"
  prot        = "udp"
}

/***
resource "aci_filter_entry" "elevated_psn_out_ah" {
  filter_dn = aci_filter.elevated_psn_out.id
  name      = "AH"
  ether_t   = "ip"
  prot      = "51"
}
***/

resource "aci_filter_entry" "elevated_psn_out_smtp" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "smtp"
  d_from_port = "smtp"
  d_to_port   = "smtp"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "elevated_psn_out_icmp_echo_reply" {
  filter_dn = aci_filter.elevated_psn_out.id
  name      = "icmp_echo_reply"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "echo-rep"
}

resource "aci_filter_entry" "elevated_psn_out_4500_udp" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "4500_udp"
  d_from_port = "4500"
  d_to_port   = "4500"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_psn_out_https" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "https"
  d_from_port = "https"
  d_to_port   = "https"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "elevated_psn_out_ntp" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "ntp"
  d_from_port = "123"
  d_to_port   = "123"
  ether_t     = "ip"
  prot        = "udp"
}

resource "aci_filter_entry" "elevated_psn_out_icmp_time_exceeded" {
  filter_dn = aci_filter.elevated_psn_out.id
  name      = "icmp_time_exceeded"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "time-exceeded"
}

/***
resource "aci_filter_entry" "elevated_psn_out_esp" {
  filter_dn = aci_filter.elevated_psn_out.id
  name      = "ESP"
  ether_t   = "ip"
  prot      = "50"
}
***/

resource "aci_filter_entry" "elevated_psn_out_8080_tcp" {
  filter_dn   = aci_filter.elevated_psn_out.id
  name        = "8080"
  d_from_port = "8080"
  d_to_port   = "8080"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "elevated_psn_out_icmp_unreachable" {
  filter_dn = aci_filter.elevated_psn_out.id
  name      = "icmp_unreachable"
  ether_t   = "ip"
  prot      = "icmp"
  icmpv4_t  = "dst-unreach"
}

##########################
#### Inbound Contract ####
##########################

resource "aci_contract" "elevated_psn_in" {
  tenant_dn = aci_tenant.elevated_psn.id
  name      = "elevated_psn_in"
  scope     = "tenant"
}

resource "aci_contract_subject" "elevated_psn_in" {
  contract_dn = aci_contract.elevated_psn_in.id
  name        = "elevated_psn_in"
  relation_vz_rs_subj_filt_att = [
    aci_filter.elevated_psn_in.id
  ]
}

###########################
#### Outbound Contract ####
###########################

resource "aci_contract" "elevated_psn_out" {
  tenant_dn = aci_tenant.elevated_psn.id
  name      = "elevated_psn_out"
  scope     = "tenant"
}

resource "aci_contract_subject" "elevated_psn_out" {
  contract_dn = aci_contract.elevated_psn_out.id
  name        = "elevated_psn_out"
  relation_vz_rs_subj_filt_att = [
    aci_filter.elevated_psn_out.id
  ]
}

#######################
#### Output Values ####
#######################

output "aci_elevated_psn_aep_domain" {
  value = aci_l3_domain_profile.elevated_psn.id
}