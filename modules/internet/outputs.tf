output "aci_internet_interface_profile" {
  value = aci_leaf_interface_profile.internet.id
}

output "tenant" {
  value = aci_tenant.internet.id
}

output "vrf" {
  value = aci_vrf.internet.id
}

output "l3out" {
  value = aci_l3_outside.internet.id
}