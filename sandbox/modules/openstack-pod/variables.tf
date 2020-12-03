variable "pod_id" {
  type        = string
  description = "The pod CI number; e.g. pod0001c"
}

variable "pod_nodes" {
  type        = list(string)
  description = "List of Node IDs in use for pod; e.g. [101,102]"
}

variable "ukcloud_mgmt_tenant" {
  type        = string
  description = "The name of the ukcloud_mgmt tenant; e.g. assured_ukcloud_mgmt"
}

variable "ukcloud_mgmt_l3_out" {
  type        = string
  description = "The name of the ukcloud_mgmt l3_out; e.g. l3_out_assured_ukcloud_mgmt"
}

variable "ukcloud_mgmt_vrf" {
  type        = string
  description = "The name of the ukcloud_mgmt vrf; e.g. vrf_assured_ukcloud_mgmt"
}

variable "internal_api_bd_subnet" {
  type        = string
  description = "The gateway/mask for the internal_api bridge domain; e.g. 10.0.0.1/24"
}

variable "ipmi_bd_subnet" {
  type        = string
  description = "The gateway/mask for the ipmi bridge domain; e.g. 10.0.1.1/24"
}

variable "mgmt_bd_subnet" {
  type        = string
  description = "The gateway/mask for the mgmt bridge domain; e.g. 10.0.2.1/24"
}

variable "mgmt_provisioning_bd_subnet" {
  type        = string
  description = "The gateway/mask for the mgmt_provisioning bridge domain; e.g. 10.0.3.1/24"
}

variable "storage_bd_subnet" {
  type        = string
  description = "The gateway/mask for the storage bridge domain; e.g. 10.0.4.1/24"
}

variable "storage_mgmt_bd_subnet" {
  type        = string
  description = "The gateway/mask for the storage_mgmt bridge domain; e.g. 10.0.5.1/24"
}

variable "tenant_bd_subnet" {
  type        = string
  description = "The gateway/mask for the storage_mgmt bridge domain; e.g. 10.0.6.1/24"
}

variable "mgmt_openstack_bd_subnet" {
  type        = string
  description = "The gateway/mask for the (internet) mgmt_openstack bridge domain; e.g. 10.0.7.1/24"
}