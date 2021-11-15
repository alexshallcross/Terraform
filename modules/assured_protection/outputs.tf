output "tenant" {
  value = aci_tenant.assured_protection.id
}

output "vrf" {
  value = aci_vrf.assured_protection.id
}

output "l3out" {
  value = aci_l3_outside.assured_protection.id
}