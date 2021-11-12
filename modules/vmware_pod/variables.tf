variable "pod_id" {
  type        = string
  description = "The pod CI number; e.g. pod0001c"
}

variable "interface_map" {
  type = map(object({
    node_ids   = list(string)
    clnt_ports = list(string)
    mgmt_ports = list(string)
    cimc_ports = list(string)
  }))
}

variable "link_level_policy" {
  type        = string
  default     = "40G"
  description = "The name of the Link Level Policy to use."
}

variable "cdp_policy" {
  type        = string
  default     = "cdp_enabled"
  description = "The name of the CDP Interface Policy to use."
}

variable "lldp_policy" {
  type        = string
  default     = "lldp_enabled"
  description = "The name of the LLDP Interface Policy to use."
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

variable "protection_tenant" {
  type        = string
  description = "The name of the protection tenant; e.g. assured_protection"
}

variable "protection_l3_out" {
  type        = string
  description = "The name of the protection l3_out; e.g. l3_out_assured_protection"
}

variable "protection_vrf" {
  type        = string
  description = "The name of the protection vrf; e.g. vrf_assured_protection"
}

variable "cimc_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_cimc bridge domain"
}

variable "storage_mgmt_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_storage_mgmt bridge domain"
}

variable "mgmt_cluster_vmware_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_vmware bridge domain"
}

variable "mgmt_cluster_tools_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_tools bridge domain"
}

variable "mgmt_cluster_vmotion_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_vmotion bridge domain"
}

variable "mgmt_cluster_avamar_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_avamar bridge domain"
}

variable "client_cluster_1_vmware_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_client_cluster_1_vmware bridge domain"
}

variable "client_cluster_1_vmotion_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_client_cluster_1_vmotion bridge domain"
}

variable "client_cluster_1_vxlan_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_client_cluster_1_vxlan bridge domain"
}

variable "mgmt_vmm_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_vmm bridge domain"
}

variable "client_avamar_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_client_avamar bridge domain"
}

variable "vmm_ci" {
  type        = string
  description = "The CI for the VMM controller; e.g vcv00004i2"
}

variable "vmm_host" {
  type        = string
  description = "The IP address or hostname for the VMM controller; e.g 10.40.16.151"
}

variable "vmm_svc_acc" {
  type        = string
  description = "The service account username and domain for VMM integration; e.g svc_pod00008-vmm@il2management"
}