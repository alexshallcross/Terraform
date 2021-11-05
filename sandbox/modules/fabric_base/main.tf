#########################
#### Local Variables ####
#########################

locals {
  flattened_inband_mgmt_ospf = flatten([
    for node_key, node in var.inband_mgmt_ospf : [
      for interface in node.interfaces : {
        node_key     = node_key
        interface_id = interface.interface_id
        address      = interface.address
      }
    ]
  ])
}

##########################
#### Pod Policy Group ####
##########################

# Step 1: Create a Policy Group called "Pod_Policy_Group"

resource "aci_rest" "pod_policy_group" {
  path       = "/api/node/mo/uni/fabric/funcprof/podpgrp-Pod_Policy_Group.json"
  class_name = "fabricPodPGrp"
  content = {
    "annotation" : "orchestrator:terraform",
    "name" : "Pod_Policy_Group"
  }
}

resource "aci_rest" "pod_policy_group_ntp_policy" {
  path       = "/api/node/mo/uni/fabric/funcprof/podpgrp-Pod_Policy_Group/rsTimePol.json"
  class_name = "fabricRsTimePol"
  content = {
    "annotation" : "orchestrator:terraform",
    "tnDatetimePolName" : "NTP_Policy"
  }
  depends_on = [
    aci_rest.pod_policy_group
  ]
}

# Step 2: Select the Fabric Policy Group "Pod_Policy_Group" as the default Profile

resource "aci_rest" "default_pod_policy_group" {
  path       = "/api/node/mo/uni/fabric/podprof-default/pods-default-typ-ALL/rspodPGrp.json"
  class_name = "fabricRsPodPGrp"
  content = {
    "annotation" : "orchestrator:terraform",
    "tDn" : "uni/fabric/funcprof/podpgrp-Pod_Policy_Group"
  }
}

# Step 3: Within BGP Route Reflector default profile, define nodes and an Autonomous System Number

resource "aci_rest" "bgp_rr_node" {
  for_each = toset(var.spine_nodes)

  path       = "/api/node/mo/uni/fabric/bgpInstP-default/rr/node-${each.value}.json"
  class_name = "bgpRRNodePEp"
  content = {
    "annotation" : "orchestrator:terraform",
    "id" = "${each.value}"
  }
}

resource "aci_rest" "bgp_as_number" {
  path       = "/api/node/mo/uni/fabric/bgpInstP-default/as.json"
  class_name = "bgpAsP"
  content = {
    "annotation" : "orchestrator:terraform",
    "asn" = var.bgp_as_number
  }
}

####################
#### NTP Policy ####
####################

resource "aci_rest" "ntp_policy" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy.json"
  class_name = "datetimePol"
  content = {
    "StratumValue" : "8",
    "adminSt" : "enabled",
    "annotation" : "orchestrator:terraform",
    "authSt" : "enabled",
    "masterMode" : "disabled",
    "serverState" : "disabled"
  }
}

resource "aci_rest" "ntp_auth_key" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpauth-1.json"
  class_name = "datetimeNtpAuthKey"
  content = {
    "annotation" : "orchestrator:terraform",
    "id" : "1",
    "key" : var.ntp_auth_key,
    "keyType" : "md5",
    "trusted" : "yes"
  }
  depends_on = [
    aci_rest.ntp_policy
  ]
}

resource "aci_rest" "ntp_provider_frn" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.40.232.11.json"
  class_name = "datetimeNtpProv"
  content = {
    "annotation" : "orchestrator:terraform",
    "keyId" : "0",
    "maxPoll" : "6",
    "minPoll" : "4",
    "name" : "10.40.232.11",
    "preferred" : "no",
    "trueChimer" : "disabled"
  }
  depends_on = [
    aci_rest.ntp_policy
  ]
}

resource "aci_rest" "ntp_provider_frn_epg" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.40.232.11/rsNtpProvToEpg.json"
  class_name = "datetimeRsNtpProvToEpg"
  content = {
    "annotation" : "orchestrator:terraform",
    "tDn" : "uni/tn-mgmt/mgmtp-default/inb-In-Band"
  }
  depends_on = [
    aci_rest.ntp_provider_frn
  ]
}

resource "aci_rest" "ntp_provider_frn_key" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.40.232.11/rsntpProvToNtpAuthKey-1.json"
  class_name = "datetimeRsNtpProvToNtpAuthKey"
  content = {
    "annotation" : "orchestrator:terraform",
    "tnDatetimeNtpAuthKeyId" : "1"
  }
  depends_on = [
    aci_rest.ntp_provider_frn
  ]
}

resource "aci_rest" "ntp_provider_cor" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.41.232.11.json"
  class_name = "datetimeNtpProv"
  content = {
    "annotation" : "orchestrator:terraform",
    "keyId" : "0",
    "maxPoll" : "6",
    "minPoll" : "4",
    "name" : "10.41.232.11",
    "preferred" : "no",
    "trueChimer" : "disabled"
  }
  depends_on = [
    aci_rest.ntp_policy
  ]
}

resource "aci_rest" "ntp_provider_cor_epg" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.41.232.11/rsNtpProvToEpg.json"
  class_name = "datetimeRsNtpProvToEpg"
  content = {
    "annotation" : "orchestrator:terraform",
    "tDn" : "uni/tn-mgmt/mgmtp-default/inb-In-Band"
  }
  depends_on = [
    aci_rest.ntp_provider_cor
  ]
}

resource "aci_rest" "ntp_provider_cor_key" {
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.41.232.11/rsntpProvToNtpAuthKey-1.json"
  class_name = "datetimeRsNtpProvToNtpAuthKey"
  content = {
    "annotation" : "orchestrator:terraform",
    "tnDatetimeNtpAuthKeyId" : "1"
  }
  depends_on = [
    aci_rest.ntp_provider_cor
  ]
}

##################
#### Timezone ####
##################

resource "aci_rest" "timezone" {
  path       = "/api/node/mo/uni/fabric/format-default.json"
  class_name = "datetimeFormat"
  content = {
    "annotation" : "orchestrator:terraform",
    "showOffset" : "enabled",
    "tz" : "p60_Europe-London"
  }
}

#####################
#### DNS Profile ####
#####################

resource "aci_rest" "dns_profile" {
  path       = "/api/node/mo/uni/fabric/dnsp-default.json"
  class_name = "dnsProfile"
  content = {
    "annotation" : "orchestrator:terraform"
  }
}

resource "aci_rest" "dns_domain_il3management" {
  path       = "/api/node/mo/uni/fabric/dnsp-default/dom-il3management.json"
  class_name = "dnsDomain"
  content = {
    "annotation" : "orchestrator:terraform",
    "isDefault" : "no",
    "name" : "il3management"
  }
  depends_on = [
    aci_rest.dns_profile
  ]
}

resource "aci_rest" "dns_domain_il3management_local" {
  path       = "/api/node/mo/uni/fabric/dnsp-default/dom-il3management.local.json"
  class_name = "dnsDomain"
  content = {
    "annotation" : "orchestrator:terraform",
    "isDefault" : "yes",
    "name" : "il3management.local"
  }
  depends_on = [
    aci_rest.dns_profile
  ]
}

resource "aci_rest" "dns_domain_provider_frn" {
  path       = "/api/node/mo/uni/fabric/dnsp-default/prov-[10.40.235.13].json"
  class_name = "dnsProv"
  content = {
    "annotation" : "orchestrator:terraform",
    "preferred" : "yes",
    "addr" : "10.40.235.13"
  }
  depends_on = [
    aci_rest.dns_profile
  ]
}

resource "aci_rest" "dns_domain_provider_cor" {
  path       = "/api/node/mo/uni/fabric/dnsp-default/prov-[10.41.235.4].json"
  class_name = "dnsProv"
  content = {
    "annotation" : "orchestrator:terraform",
    "preferred" : "no",
    "addr" : "10.41.235.4"
  }
  depends_on = [
    aci_rest.dns_profile
  ]
}

################################
#### CDP Interface Policies ####
################################

resource "aci_cdp_interface_policy" "disabled" {
  name     = "cdp_disabled"
  admin_st = "disabled"
}

resource "aci_cdp_interface_policy" "enabled" {
  name     = "cdp_enabled"
  admin_st = "enabled"
}

#################################
#### LLDP Interface Policies ####
#################################

resource "aci_lldp_interface_policy" "disabled" {
  name        = "lldp_disabled"
  admin_rx_st = "disabled"
  admin_tx_st = "disabled"
}

resource "aci_lldp_interface_policy" "enabled" {
  name        = "lldp_enabled"
  admin_rx_st = "enabled"
  admin_tx_st = "enabled"
}

#######################
#### LACP Policies ####
#######################

resource "aci_lacp_policy" "enabled" {
  name      = "lacp_active"
  ctrl      = ["fast-sel-hot-stdby", "susp-individual", "graceful-conv"]
  max_links = "16"
  min_links = "1"
  mode      = "active"
}

#######################################
#### Interface Link Level Policies ####
#######################################

resource "aci_fabric_if_pol" "_1G" {
  name          = "1G"
  auto_neg      = "on"
  link_debounce = "100"
  speed         = "1G"
}

resource "aci_fabric_if_pol" "_1G_no_auto_neg" {
  name          = "1G_no_auto_neg"
  auto_neg      = "off"
  link_debounce = "100"
  speed         = "1G"
}

resource "aci_fabric_if_pol" "_10G" {
  name          = "10G"
  auto_neg      = "on"
  link_debounce = "100"
  speed         = "10G"
}

resource "aci_fabric_if_pol" "_10G_no_auto_neg" {
  name          = "10G_no_auto_neg"
  auto_neg      = "off"
  link_debounce = "100"
  speed         = "10G"
}

resource "aci_fabric_if_pol" "_40G" {
  name          = "40G"
  auto_neg      = "on"
  link_debounce = "100"
  speed         = "40G"
}

resource "aci_fabric_if_pol" "_40G_no_auto_neg" {
  name          = "40G_no_auto_neg"
  auto_neg      = "off"
  link_debounce = "100"
  speed         = "40G"
}

##############################################
#### In-Band Management - Fabric Policies ####
##############################################

# Step 1 - Create VLAN Pool

resource "aci_vlan_pool" "inband_mgmt" {
  name       = "vlan_static_inband_mgmt"
  alloc_mode = "static"
}

resource "aci_ranges" "inband_mgmt" {
  vlan_pool_dn = aci_vlan_pool.inband_mgmt.id
  from         = "vlan-10"
  to           = "vlan-10"
  alloc_mode   = "static"
}

# Step 2 - Create Physical domain

resource "aci_physical_domain" "inband_mgmt" {
  name = "inband_mgmt"

  relation_infra_rs_vlan_ns = aci_vlan_pool.inband_mgmt.id
}

# Step 3 - Create AEP

resource "aci_attachable_access_entity_profile" "inband_mgmt" {
  name = "inband_mgmt"

  relation_infra_rs_dom_p = [
    aci_physical_domain.inband_mgmt.id
  ]
}

# Step 4 - Create interface policy group

resource "aci_leaf_access_port_policy_group" "inband_mgmt" {
  name = "apic_controllers"

  relation_infra_rs_h_if_pol    = aci_fabric_if_pol._40G.id
  relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.enabled.id
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.enabled.id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.inband_mgmt.id
}

# Step 5 Create interface profile

resource "aci_leaf_interface_profile" "inband_mgmt" {
  name = "apic_controllers"
}

resource "aci_access_port_selector" "port_46" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.inband_mgmt.id
  name                           = "Port-46"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.inband_mgmt.id
}

resource "aci_access_port_block" "port_46" {
  access_port_selector_dn = aci_access_port_selector.port_46.id
  from_card               = "1"
  from_port               = "46"
  to_card                 = "1"
  to_port                 = "46"
}

resource "aci_access_port_selector" "port_47" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.inband_mgmt.id
  name                           = "Port-47"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.inband_mgmt.id
}

resource "aci_access_port_block" "port_47" {
  access_port_selector_dn = aci_access_port_selector.port_47.id
  from_card               = "1"
  from_port               = "47"
  to_card                 = "1"
  to_port                 = "47"
}

resource "aci_access_port_selector" "port_48" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.inband_mgmt.id
  name                           = "Port-48"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.inband_mgmt.id
}

resource "aci_access_port_block" "port_48" {
  access_port_selector_dn = aci_access_port_selector.port_48.id
  from_card               = "1"
  from_port               = "48"
  to_card                 = "1"
  to_port                 = "48"
}

resource "aci_leaf_profile" "inband_mgmt" {
  name = "inband_mgmt_profile"

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.inband_mgmt.id
  ]
}

resource "aci_leaf_selector" "inband_mgmt" {
  leaf_profile_dn         = aci_leaf_profile.inband_mgmt.id
  name                    = "inband_mgmt_switch_selector"
  switch_association_type = "range"
}

resource "aci_node_block" "inband_mgmt" {
  switch_association_dn = aci_leaf_selector.inband_mgmt.id
  name                  = "inband_mgmt"
  from_                 = "901"
  to_                   = "902"
}

##############################################################
#### In-Band Management -  L3 Out External Routed Network ####
##############################################################

# Step 1 - Create the VLAN pool

resource "aci_vlan_pool" "elevated_mgmt" {
  name       = "vlan_static_l3_out_elevated_mgmt"
  alloc_mode = "static"
}

resource "aci_ranges" "elevated_mgmt" {
  vlan_pool_dn = aci_vlan_pool.elevated_mgmt.id
  from         = "vlan-${var.inband_mgmt_vlan}"
  to           = "vlan-${var.inband_mgmt_vlan}"
  alloc_mode   = "static"
  role         = "external"
}

# Step 2 - Create the external routed domain

resource "aci_l3_domain_profile" "elevated_mgmt" {
  name                      = "l3_out_elevated_mgmt"
  relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_mgmt.id
}

# Step 3 - Create the AEP

resource "aci_attachable_access_entity_profile" "elevated_mgmt" {
  name                    = "elevated_private_peering"
  relation_infra_rs_dom_p = [aci_l3_domain_profile.elevated_mgmt.id]
}

resource "aci_attachable_access_entity_profile" "assured_mgmt" {
  name                    = "assured_private_peering"
  relation_infra_rs_dom_p = var.assured_private_peering_domains
}

# Step 4 - Create the Interface Policy Group

resource "aci_leaf_access_port_policy_group" "elevated_mgmt" {
  name = "elevated_private_peering"

  relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.enabled.id
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.enabled.id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.elevated_mgmt.id
}

resource "aci_leaf_access_port_policy_group" "assured_mgmt" {
  name = "assured_private_peering"

  relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.enabled.id
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.enabled.id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.assured_mgmt.id
}

# Step 5 - Create the Interface Profile

resource "aci_leaf_interface_profile" "elevated_mgmt" {
  name = "elevated_private_peering"
}

resource "aci_access_port_selector" "port_33" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.elevated_mgmt.id
  name                           = "Port-33"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.elevated_mgmt.id
}

resource "aci_access_port_block" "port_33" {
  access_port_selector_dn = aci_access_port_selector.port_33.id
  from_card               = "1"
  from_port               = "33"
  to_card                 = "1"
  to_port                 = "33"
}

resource "aci_access_port_selector" "port_34" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.elevated_mgmt.id
  name                           = "Port-34"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.elevated_mgmt.id
}

resource "aci_access_port_block" "port_34" {
  access_port_selector_dn = aci_access_port_selector.port_34.id
  from_card               = "1"
  from_port               = "34"
  to_card                 = "1"
  to_port                 = "34"
}

resource "aci_leaf_interface_profile" "assured_mgmt" {
  name = "assured_private_peering"
}

resource "aci_access_port_selector" "port_17" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.assured_mgmt.id
  name                           = "Port-17"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.assured_mgmt.id
}

resource "aci_access_port_block" "port_17" {
  access_port_selector_dn = aci_access_port_selector.port_17.id
  from_card               = "1"
  from_port               = "17"
  to_card                 = "1"
  to_port                 = "17"
}

resource "aci_access_port_selector" "port_18" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.assured_mgmt.id
  name                           = "Port-18"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.assured_mgmt.id
}

resource "aci_access_port_block" "port_18" {
  access_port_selector_dn = aci_access_port_selector.port_18.id
  from_card               = "1"
  from_port               = "18"
  to_card                 = "1"
  to_port                 = "18"
}

# Step 6 - Create Leaf profile

resource "aci_leaf_profile" "elevated_mgmt" {
  name = "elevated_private_peering"

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.elevated_mgmt.id
  ]
}

resource "aci_leaf_selector" "elevated_mgmt" {
  leaf_profile_dn         = aci_leaf_profile.elevated_mgmt.id
  name                    = "elevated_private_peering_switch_selector"
  switch_association_type = "range"
}

resource "aci_node_block" "elevated_mgmt" {
  switch_association_dn = aci_leaf_selector.elevated_mgmt.id
  name                  = "elevated_mgmt"
  from_                 = "901"
  to_                   = "904"
}

resource "aci_leaf_profile" "assured_mgmt" {
  name = "assured_private_peering"

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.assured_mgmt.id
  ]
}

resource "aci_leaf_selector" "assured_mgmt" {
  leaf_profile_dn         = aci_leaf_profile.assured_mgmt.id
  name                    = "assured_private_peering_switch_selector"
  switch_association_type = "range"
}

resource "aci_node_block" "assured_mgmt" {
  switch_association_dn = aci_leaf_selector.assured_mgmt.id
  name                  = "assured_mgmt"
  from_                 = "901"
  to_                   = "904"
}

#######################################
#### In-Band Management -  Layer 3 ####
#######################################

# Step 1 - Create OSPF profile 

resource "aci_ospf_interface_policy" "elevated_mgmt" {
  tenant_dn = "uni/tn-mgmt"
  name      = "ospf_int_p2p_protocol_policy_elevated_mgmt"
}

# Step 2 - Create external network peering

resource "aci_l3_outside" "elevated_mgmt" {
  name                         = "l3_out_elevated_mgmt"
  tenant_dn                    = "uni/tn-mgmt"
  relation_l3ext_rs_ectx       = "uni/tn-mgmt/ctx-inb"
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.elevated_mgmt.id
}

resource "aci_logical_node_profile" "elevated_mgmt" {
  l3_outside_dn = aci_l3_outside.elevated_mgmt.id
  name          = "ospf_node_profile_mgmt"
}

resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node" {
  for_each = var.inband_mgmt_ospf

  logical_node_profile_dn = aci_logical_node_profile.elevated_mgmt.id
  tdn                     = "topology/pod-1/node-${each.key}"
  rtr_id                  = each.value.router_id
}

resource "aci_logical_interface_profile" "elevated_mgmt" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_mgmt.id
  name                    = "ospf_int_profile_mgmt"
}

resource "aci_l3out_ospf_interface_profile" "elevated_mgmt" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.elevated_mgmt.id
}

resource "aci_l3out_path_attachment" "elevated_mgmt" {
  for_each = {
    for interface in local.flattened_inband_mgmt_ospf : "${interface.node_key}.${interface.interface_id}" => interface
  }

  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-${each.value.node_key}/pathep-[${each.value.interface_id}]"
  if_inst_t                    = "sub-interface"
  addr                         = each.value.address
  encap                        = "vlan-${var.inband_mgmt_ospf_interface_vlan}"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_external_network_instance_profile" "elevated_mgmt" {
  l3_outside_dn = aci_l3_outside.elevated_mgmt.id
  name          = "all"
}

resource "aci_l3_ext_subnet" "all" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.elevated_mgmt.id
  ip                                   = "0.0.0.0/0"
}

resource "aci_l3out_ospf_external_policy" "example" {
  l3_outside_dn = aci_l3_outside.elevated_mgmt.id
  area_cost     = "1"
  area_ctrl     = "redistribute,summary"
  area_id       = "0.0.0.5"
  area_type     = "regular"
}

# Step 3 - Create the Bridge Domain for In-Band Management Network

resource "aci_subnet" "inb_subnet" {
  parent_dn = aci_bridge_domain.inb.id
  ip        = var.inband_mgmt_subnet_gateway
  scope = [
    "public"
  ]
}

# Step 4 - Associate the L3 Out with the inb Bridge Domain

resource "aci_bridge_domain" "inb" {
  tenant_dn = "uni/tn-mgmt"
  name      = "inb"
  relation_fv_rs_bd_to_out = [
    aci_l3_outside.elevated_mgmt.id
  ]
  relation_fv_rs_ctx = "uni/tn-mgmt/ctx-inb"
}

# Step 5 - Create Static Node Management Addresses and In-Band Node Management EPG

resource "aci_node_mgmt_epg" "in_band" {
  type                  = "in_band"
  management_profile_dn = "uni/tn-mgmt/mgmtp-default"
  name                  = "In_Band"
  encap                 = "vlan-10"
}

resource "aci_static_node_mgmt_address" "node_address" {
  for_each          = var.inband_mgmt_node_address
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-${each.key}"
  type              = "in_band"
  addr              = each.value
  #Below function trims the subnet mask from the variable used for the BD
  gw = trim(var.inband_mgmt_subnet_gateway, substr(var.inband_mgmt_subnet_gateway, -3, -1))
}

# Step 6 - Create Out of Band Node Management EPG

resource "aci_node_mgmt_epg" "out_of_band_example" {
  type                  = "out_of_band"
  management_profile_dn = "uni/tn-mgmt/mgmtp-default"
  name                  = "Out-of-Band"
}

#################################
#### Disable Remote EP Learn ####
#################################

resource "aci_rest" "settings" {
  path       = "/api/node/mo/uni/infra/settings.json"
  class_name = "infraSetPol"
  content = {
    "annotation" : "orchestrator:terraform",
    "unicastXrEpLearnDisable" : "yes"
  }
}

##########################
#### Configure Syslog ####
##########################

# Step 1 - Configure syslog collectors

resource "aci_rest" "syslog_group" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile.json"
  class_name = "syslogGroup"
  content = {
    "annotation" : "orchestrator:terraform"
  }
}

resource "aci_rest" "syslog_console" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile/console.json"
  class_name = "syslogConsole"
  content = {
    "annotation" : "orchestrator:terraform",
    "adminState" : "enabled",
    "format" : "aci",
    "severity" : "alerts"
  }
  depends_on = [
    aci_rest.syslog_group
  ]
}

resource "aci_rest" "syslog_file" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile/file.json"
  class_name = "syslogFile"
  content = {
    "annotation" : "orchestrator:terraform",
    "adminState" : "enabled",
    "format" : "aci",
    "severity" : "information"
  }
  depends_on = [
    aci_rest.syslog_group
  ]
}

resource "aci_rest" "syslog_prof" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile/prof.json"
  class_name = "syslogProf"
  content = {
    "annotation" : "orchestrator:terraform",
    "adminState" : "enabled",
    "name" : "syslog"
  }
  depends_on = [
    aci_rest.syslog_group
  ]
}

resource "aci_rest" "syslog_remote_dest_frn" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile/rdst-10.40.236.3.json"
  class_name = "syslogRemoteDest"
  content = {
    "annotation" : "orchestrator:terraform",
    "adminState" : "enabled",
    "format" : "aci",
    "forwardingFacility" : "local7",
    "host" : "10.40.236.3",
    "name" : "10.40.236.3",
    "port" : "514",
    "severity" : "information"
  }
  depends_on = [
    aci_rest.syslog_group
  ]
}

resource "aci_rest" "syslog_remote_dest_frn_to_epg" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile/rdst-10.40.236.3/rsARemoteHostToEpg.json"
  class_name = "fileRsARemoteHostToEpg"
  content = {
    "annotation" : "orchestrator:terraform",
    "tDn" : "uni/tn-mgmt/mgmtp-default/inb-In-Band"
  }
  depends_on = [
    aci_rest.syslog_remote_dest_frn
  ]
}

resource "aci_rest" "syslog_remote_dest_cor" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile/rdst-10.41.236.9.json"
  class_name = "syslogRemoteDest"
  content = {
    "annotation" : "orchestrator:terraform",
    "adminState" : "enabled",
    "format" : "aci",
    "forwardingFacility" : "local7",
    "host" : "10.41.236.9",
    "name" : "10.41.236.9",
    "port" : "514",
    "severity" : "information"
  }
  depends_on = [
    aci_rest.syslog_group
  ]
}

resource "aci_rest" "syslog_remote_dest_cor_to_epg" {
  path       = "/api/node/mo/uni/fabric/slgroup-Syslog_Profile/rdst-10.41.236.9/rsARemoteHostToEpg.json"
  class_name = "fileRsARemoteHostToEpg"
  content = {
    "annotation" : "orchestrator:terraform",
    "tDn" : "uni/tn-mgmt/mgmtp-default/inb-In-Band"
  }
  depends_on = [
    aci_rest.syslog_remote_dest_cor
  ]
}

# Step 2 - Configure fabric policy

resource "aci_rest" "syslog_src" {
  path       = "/api/node/mo/uni/fabric/moncommon/slsrc-Syslog_policy.json"
  class_name = "syslogSrc"
  content = {
    "annotation" : "orchestrator:terraform",
    "incl" : "audit,events,faults",
    "minSev" : "information"
  }
}

resource "aci_rest" "syslog_dest_group" {
  path       = "/api/node/mo/uni/fabric/moncommon/slsrc-Syslog_policy/rsdestGroup.json"
  class_name = "syslogRsDestGroup"
  content = {
    "annotation" : "orchestrator:terraform",
    "tDn" : "uni/fabric/slgroup-Syslog_Profile"
  }
  depends_on = [
    aci_rest.syslog_src
  ]
}

#####################
#### Assured CDS ####
#####################

resource "aci_tenant" "assured_cds" {
  name = "assured_cds"
}

#############
#### DOM ####
#############

resource "aci_rest" "fabric_node_control_dom" {
  path       = "/api/node/mo/uni/fabric/nodecontrol-fabric_node_control_dom.json"
  class_name = "fabricNodeControl"
  content = {
    "annotation" : "orchestrator:terraform",
    "name" : "fabric_node_control_dom",
    "featureSel" : "telemetry",
    "control" : "Dom"
  }
}

resource "aci_rest" "leaf_switch_policy_dom" {
  path       = "/api/node/mo/uni/fabric/funcprof/lenodepgrp-leaf_switch_policy_dom.json"
  class_name = "fabricLeNodePGrp"
  content = {
    "annotation" : "orchestrator:terraform",
    "name" : "leaf_switch_policy_dom"
  }
}

resource "aci_rest" "leaf_switch_policy_dom_node_control" {
  path       = "/api/node/mo/uni/fabric/funcprof/lenodepgrp-leaf_switch_policy_dom/rsnodeCtrl.json"
  class_name = "fabricRsNodeCtrl"
  content = {
    "annotation" : "orchestrator:terraform",
    "tnFabricNodeControlName" : "fabric_node_control_dom"
  }
  depends_on = [
    aci_rest.leaf_switch_policy_dom
  ]
}

resource "aci_rest" "leaf_switch_profile_dom" {
  path       = "/api/node/mo/uni/fabric/leprof-leaf_switch_profile_dom.json"
  class_name = "fabricLeafP"
  content = {
    "annotation" : "orchestrator:terraform",
    "name" : "leaf_switch_profile_dom"
  }
}

resource "aci_rest" "leaf_switch_profile_dom_leaf" {
  path       = "/api/node/mo/uni/fabric/leprof-leaf_switch_profile_dom/leaves-border_leaf-typ-range.json"
  class_name = "fabricLeafS"
  content = {
    "annotation" : "orchestrator:terraform",
    "type" : "range"
  }
  depends_on = [
    aci_rest.leaf_switch_profile_dom
  ]
}

resource "aci_rest" "leaf_switch_profile_dom_leaf_selector" {
  path       = "/api/node/mo/uni/fabric/leprof-leaf_switch_profile_dom/leaves-border_leaf-typ-range/nodeblk-border_leaf_selector.json"
  class_name = "fabricNodeBlk"
  content = {
    "annotation" : "orchestrator:terraform",
    "name" : "border_leaf_selector"
    "from_" : min(keys(var.inband_mgmt_ospf)...)
    "to_" : max(keys(var.inband_mgmt_ospf)...)
  }
  depends_on = [
    aci_rest.leaf_switch_profile_dom_leaf
  ]
}

resource "aci_rest" "leaf_switch_profile_dom_policy_selector" {
  path       = "/api/node/mo/uni/fabric/leprof-leaf_switch_profile_dom/leaves-border_leaf-typ-range/rsleNodePGrp.json"
  class_name = "fabricRsLeNodePGrp"
  content = {
    "annotation" : "orchestrator:terraform",
    "tDn" : "uni/fabric/funcprof/lenodepgrp-leaf_switch_policy_dom"
  }
  depends_on = [
    aci_rest.leaf_switch_profile_dom_leaf
  ]
}

#####################
#### Assured CDS ####
#####################

resource "aci_tenant" "elevated_cds" {
  name = "elevated_cds"
}

#######################
#### Output Values ####
#######################

output "aci_fabric_if_pol_10G" {
  value = aci_fabric_if_pol._10G.id
}

output "aci_cdp_interface_policy_disabled" {
  value = aci_cdp_interface_policy.disabled.id
}

output "aci_lldp_interface_policy_enabled" {
  value = aci_lldp_interface_policy.enabled.id
}