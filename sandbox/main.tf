##### APIC Login

provider "aci" {
  username = var.username
  password = var.password
  url      = "https://sandboxapicdc.cisco.com"
  insecure = false
}

##### Modules

module "openstack" {
  source    = "./modules/openstack-pod"
  for_each  = var.openstack_pods

  pod_id    = each.value.pod_id
  pod_nodes = each.value.pod_nodes

  ukcloud_mgmt_tenant = each.value.ukcloud_mgmt_tenant
  ukcloud_mgmt_l3_out = each.value.ukcloud_mgmt_l3_out
  ukcloud_mgmt_vrf    = each.value.ukcloud_mgmt_vrf

  internal_api_bd_subnet      = each.value.internal_api_bd_subnet
  ipmi_bd_subnet              = each.value.ipmi_bd_subnet
  mgmt_bd_subnet              = each.value.mgmt_bd_subnet
  mgmt_provisioning_bd_subnet = each.value.mgmt_provisioning_bd_subnet
  storage_bd_subnet           = each.value.storage_bd_subnet
  storage_mgmt_bd_subnet      = each.value.storage_mgmt_bd_subnet
  tenant_bd_subnet            = each.value.tenant_bd_subnet
  mgmt_openstack_bd_subnet    = each.value.mgmt_openstack_bd_subnet
}