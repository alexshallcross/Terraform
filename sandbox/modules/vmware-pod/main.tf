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