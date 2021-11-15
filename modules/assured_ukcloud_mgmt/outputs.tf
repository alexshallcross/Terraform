output "tenant" {
  value = aci_tenant.assured_ukcloud_mgmt.id
}

output "vrf" {
  value = aci_vrf.assured_ukcloud_mgmt.id
}

output "l3out" {
  value = aci_l3_outside.assured_ukcloud_mgmt.id
}