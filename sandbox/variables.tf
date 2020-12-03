variable "openstack_pods" {
    type = map(object({
        pod_id = string
        pod_nodes = list(string)
        ukcloud_mgmt_tenant = string
        ukcloud_mgmt_l3_out = string
        ukcloud_mgmt_vrf = string
        internal_api_bd_subnet = string
        ipmi_bd_subnet = string
        mgmt_bd_subnet = string
        mgmt_provisioning_bd_subnet = string
        storage_bd_subnet = string
        storage_mgmt_bd_subnet = string
        tenant_bd_subnet = string
        mgmt_openstack_bd_subnet = string
    }))
}