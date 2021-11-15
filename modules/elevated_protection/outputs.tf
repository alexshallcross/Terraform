output "tenant" {
  value = aci_tenant.elevated_protection.id
}

output "vrf" {
  value = aci_vrf.elevated_protection.id
}

output "l3out" {
  value = aci_l3_outside.elevated_protection.id
}