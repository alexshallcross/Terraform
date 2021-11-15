output "tenant" {
  value = aci_tenant.elevated_ukcloud_mgmt.id
}

output "vrf" {
  value = aci_vrf.elevated_ukcloud_mgmt.id
}

output "l3out" {
  value = aci_l3_outside.elevated_ukcloud_mgmt.id
}