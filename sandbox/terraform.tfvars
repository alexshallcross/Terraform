a_username = "admin"
b_password = "!v3G@!4@Y"

openstack_pods = {
  pod00001 = {
    pod_id    = "pod00001"
    pod_nodes = [201, 202]

    ukcloud_mgmt_tenant = "burgers"
    ukcloud_mgmt_l3_out = "burgers"
    ukcloud_mgmt_vrf    = "burgers"

    internal_api_bd_subnet      = "10.0.0.1/24"
    ipmi_bd_subnet              = "10.0.1.1/24"
    mgmt_bd_subnet              = "10.0.2.1/24"
    mgmt_provisioning_bd_subnet = "10.0.3.1/24"
    storage_bd_subnet           = "10.0.4.1/24"
    storage_mgmt_bd_subnet      = "10.0.5.1/24"
    tenant_bd_subnet            = "10.0.6.1/24"
    mgmt_openstack_bd_subnet    = "10.0.7.1/23"
  }
}