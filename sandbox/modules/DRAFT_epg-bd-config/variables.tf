variable "pod_id" {
  type        = string
  description = "The pod CI number; e.g. pod0001c"
}

variable "epg_name" {
  type        = string
  description = "The name of the epg without the pod ID, e.g cimc or vmware_mgmt"
}

variable "app_prof" {
  type        = string
  description = "The name of the application profile that will contain the EPG, e.g. pod0001c_vmware"
}

variable "phys_dom" {
  type        = string
  description = "The name of the physical domain associated the EPG is linked to, e.g. pod0001c_vmware"
}

variable "tenant" {
  type        = string
  description = "The name of the tenant that the BD resides in, e.g. elevated_ukcloud_mgmt"
}

variable "l3_out" {
  type        = string
  description = "The name of the l3_out that the BD uses, e.g. l3_out_elevated_ukcloud_mgmt"
}

variable "vrf" {
  type        = string
  description = "The name of the vrf that the BD is linked to, e.g. vrf_elevated_ukcloud_mgmt"
}