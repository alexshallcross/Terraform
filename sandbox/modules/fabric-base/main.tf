##########################
#### Pod Policy Group ####
##########################

# Step 1: Create a Policy Group called "Pod_Policy_Group"

resource "aci_rest" "pod_policy_group" {
  path       = "/api/node/mo/uni/fabric/funcprof/podpgrp-Pod_Policy_Group.json"
  class_name = "fabricPodPGrp"
  content = {
    "annotation" : "orchestrator:terraform",
    "descr" : "",
    "dn" : "uni/fabric/funcprof/podpgrp-Pod_Policy_Group",
    "name" : "Pod_Policy_Group",
    "nameAlias" : "",
    "ownerKey" : "",
    "ownerTag" : ""
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
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.40.232.11/rsNtpProvToNtpAuthKey.json"
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
  path       = "/api/node/mo/uni/fabric/time-NTP_policy/ntpprov-10.41.232.11/rsNtpProvToNtpAuthKey.json"
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
    "annotation" : "orchestrator:terraform",
    "epgDn" : "uni/tn-mgmt/mgmtp-default/inb-In-Band"
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
  name          = "1G"
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
  name          = "10G"
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
  name          = "40G"
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
  _from        = "vlan-10"
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
  name                  = "e96125f97531b1d1"
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
  _from        = "vlan-3900"
  to           = "vlan-3900"
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
  relation_infra_rs_dom_p = aci_l3_domain_profile.elevated_mgmt.id
}

# Step 4 - Create the Interface Policy Group

resource "aci_leaf_access_port_policy_group" "elevated_mgmt" {
  name = "elevated_private_peering"

  relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.enabled.id
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.enabled.id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.elevated_private_peering.id
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
  from_port               = "46"
  to_card                 = "1"
  to_port                 = "46"
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
  name                  = "a1f2705d1ge02z7j"
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
  relation_l3ext_rs_ectx       = "inb"
  relation_l3ext_rs_l3_dom_att = aci_l3_domain_profile.elevated_mgmt.id
}

resource "aci_logical_node_profile" "elevated_mgmt" {
  l3_outside_dn = aci_l3_outside.elevated_mgmt.id
  name          = "ospf_node_profile_mgmt"
}

resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_901" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_mgmt.id
  tDn                     = "topology/pod-1/node-901"
  rtr_id                  = "10.41.37.2"
}

resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_902" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_mgmt.id
  tDn                     = "topology/pod-1/node-902"
  rtr_id                  = "10.41.37.10"
}

resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_903" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_mgmt.id
  tDn                     = "topology/pod-1/node-903"
  rtr_id                  = "10.41.37.18"
}

resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_904" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_mgmt.id
  tDn                     = "topology/pod-1/node-904"
  rtr_id                  = "10.41.37.26"
}

resource "aci_logical_interface_profile" "elevated_mgmt" {
  logical_node_profile_dn = aci_logical_node_profile.elevated_mgmt.id
  name                    = "ospf_int_profile_mgmt"
  tag                     = "yellow-green"
}

resource "aci_l3out_ospf_interface_profile" "example" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  auth_key                     = "key"
  auth_key_id                  = "1"
  auth_type                    = "md5"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.elevated_mgmt.id
}

resource "aci_l3out_path_attachment" "901_33" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-901/pathep-[eth1/33]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.2/30"
  encap                        = "vlan-3900"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_path_attachment" "901_34" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-901/pathep-[eth1/34]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.6/30"
  encap                        = "vlan-3900"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_path_attachment" "902_33" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-902/pathep-[eth1/33]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.14/30"
  encap                        = "vlan-3900"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_path_attachment" "902_34" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-902/pathep-[eth1/34]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.10/30"
  encap                        = "vlan-3900"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_path_attachment" "903_33" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-903/pathep-[eth1/33]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.18/30"
  encap                        = "vlan-3900"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_path_attachment" "903_34" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-903/pathep-[eth1/34]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.22/30"
  encap                        = "vlan-3900"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_path_attachment" "904_33" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-904/pathep-[eth1/33]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.26/30"
  encap                        = "vlan-3900"
  encap_scope                  = "local"
  mode                         = "regular"
  mtu                          = "9000"
}

resource "aci_l3out_path_attachment" "904_34" {
  logical_interface_profile_dn = aci_logical_interface_profile.elevated_mgmt.id
  target_dn                    = "topology/pod-1/paths-904/pathep-[eth1/34]"
  if_inst_t                    = "sub-interface"
  addr                         = "10.41.36.30/30"
  encap                        = "vlan-3900"
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
  ip        = "10.41.1.1/25"
  scope = [
    "public"
  ]
}

# Step 4 - Associate the L3 Out with the inb Bridge Domain

resource "aci_bridge_domain" "inb" {
  tenant_dn = "uni/tn-mgmt/"
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

resource "aci_static_node_mgmt_address" "node_1" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-1"
  type              = "in_band"
  addr              = "10.41.1.11/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_2" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-2"
  type              = "in_band"
  addr              = "10.41.1.12/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_3" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-3"
  type              = "in_band"
  addr              = "10.41.1.13/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_1001" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-1001"
  type              = "in_band"
  addr              = "10.41.1.21/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_1002" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-1002"
  type              = "in_band"
  addr              = "10.41.1.22/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_1003" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-1003"
  type              = "in_band"
  addr              = "10.41.1.23/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_1004" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-1004"
  type              = "in_band"
  addr              = "10.41.1.24/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_901" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-901"
  type              = "in_band"
  addr              = "10.41.1.31/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_902" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-902"
  type              = "in_band"
  addr              = "10.41.1.32/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_903" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-903"
  type              = "in_band"
  addr              = "10.41.1.33/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_904" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-904"
  type              = "in_band"
  addr              = "10.41.1.34/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_101" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-101"
  type              = "in_band"
  addr              = "10.41.1.51/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_102" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-102"
  type              = "in_band"
  addr              = "10.41.1.52/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_103" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-103"
  type              = "in_band"
  addr              = "10.41.1.53/25"
  gw                = "10.41.1.1"
}

resource "aci_static_node_mgmt_address" "node_104" {
  management_epg_dn = aci_node_mgmt_epg.in_band.id
  t_dn              = "topology/pod-1/node-104"
  type              = "in_band"
  addr              = "10.41.1.54/25"
  gw                = "10.41.1.1"
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
    "annotation" : "orchestrator:terraform",
    "dn" : "uni/infra/settings",
    "name" : "default",
    "unicastXrEpLearnDisable" : "yes"
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
  class_name = "filersARemoteHostToEpg"
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
  class_name = "filersARemoteHostToEpg"
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
    "tDn": "uni/fabric/slgroup-Syslog_Profile"
  }
  depends_on = [
    aci_rest.syslog_src
  ]
}