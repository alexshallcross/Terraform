### Create the EPG

resource "aci_application_epg" "epg" {
  # Name the EPG by combining the pod and EPG name
  name = join("", [var.pod_id, "_", var.epg_name])

  # The Application profile the EPG is to be created under
  application_profile_dn = var.app_prof

  # Bind to bridge domain 
  relation_fv_rs_bd = aci_bridge_domain.bd.id

  # Provide default contract
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]

  # Consume default contract
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]

  /***
  The relation_fv_rs_graph_def attribute should be ignored as Terraform will write 
  a null value to it, which will be immediately overwritten by the APIC to a different 
  value, resulting in a change showing each time a run is planned.
  ***/
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

### Link the EPG to a physical domain

resource "aci_epg_to_domain" "epg" {
  application_epg_dn = aci_application_epg.epg.id
  tdn                = var.phys_dom
}

### Link the EPG to an AEP

# Links the "podxxxxx_mgmt_cluster_avamar" EPG and VLAN tag to the Client ESX AEP
resource "aci_epgs_using_function" "epg_to_aep" {
  access_generic_dn = var.access_generic_id
  tdn               = aci_application_epg.epg.id
  encap             = var.vlan_tag
  instr_imedcy      = "immediate"
  mode              = "regular"
}

### Create the bridge domain

resource "aci_bridge_domain" "bd" {
  # Name the EPG by combining the pod and EPG name
  name = join("", [var.pod_id, "_", var.epg_name])

  # The tenant that the BD is created under
  tenant_dn = var.tenant

  # Set endpoint move detection to GARP
  ep_move_detect_mode = "garp"

  # Set the BD to L3 out relation
  relation_fv_rs_bd_to_out = [
    var.l3_out
  ]

  # Set the BD to VRF relation
  relation_fv_rs_ctx = var.vrf
}

### Create subnet

resource "aci_subnet" "subnet" {
  for_each = toset(var.subnets)

  parent_dn = aci_bridge_domain.bd.id
  ip        = each.value
  scope = [
    "public"
  ]
}