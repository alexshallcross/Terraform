#### Local Variables ####

locals {
  flattened_client_interface_map = flatten([
    for pair_key, pair in var.interface_map : [
      for port in pair.clnt_ports : {
        pair_key = pair_key
        port     = port
      }
    ]
  ])
}

#### Switch Profile ####

resource "aci_leaf_profile" "vmware" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_vmware_", each.key])

  relation_infra_rs_acc_port_p = [
    aci_leaf_interface_profile.client_esx[each.key].id
  ]
}

resource "aci_leaf_selector" "vmware" {
  for_each = var.interface_map

  leaf_profile_dn         = aci_leaf_profile.vmware[each.key].id
  name                    = join("", [var.pod_id, "_vmware_", each.key])
  switch_association_type = "range"
}

resource "aci_node_block" "vmware" {
  for_each = var.interface_map

  switch_association_dn = aci_leaf_selector.vmware[each.key].id
  
  name  = join("", [var.pod_id, "_", each.key])
  from_ = each.value.node_ids[0]
  to_   = each.value.node_ids[1]
}

#### Client Interface Profile ####

resource "aci_leaf_interface_profile" "client_esx" {
  for_each = var.interface_map

  name = join("", [var.pod_id, "_", each.key, "_client_esx"])
}

resource "aci_access_port_selector" "client_esx" {
  for_each = var.interface_map

  leaf_interface_profile_dn      = aci_leaf_interface_profile.client_esx[each.key].id
  name                           = join("", [var.pod_id, "_", each.key, "_client_esx"])
  access_port_selector_type      = "range"
  #relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.client_esx.id
}

resource "aci_access_port_block" "client_esx" {
  for_each = {
    for interface in local.flattened_client_interface_map : "${interface.pair_key}.${interface.port}" => interface
  }

  access_port_selector_dn = aci_access_port_selector.client_esx[each.value.pair_key].id
  name                    = join("", [var.pod_id, "_", each.value.pair_key, "_port_", each.value.port])
  from_port               = each.value.port
  to_port                 = each.value.port
}