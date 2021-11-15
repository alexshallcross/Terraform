output "aci_fabric_if_pol_40G" {
  value = aci_fabric_if_pol._40G.id
}

output "aci_cdp_interface_policy_enabled" {
  value = aci_cdp_interface_policy.enabled.id
}

output "aci_cdp_interface_policy_disabled" {
  value = aci_cdp_interface_policy.disabled.id
}

output "aci_lldp_interface_policy_enabled" {
  value = aci_lldp_interface_policy.enabled.id
}

output "aci_lldp_interface_policy_disabled" {
  value = aci_lldp_interface_policy.disabled.id
}