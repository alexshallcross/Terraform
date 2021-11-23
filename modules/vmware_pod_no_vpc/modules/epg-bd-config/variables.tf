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
  type        = list(string)
  description = "The name of the l3_out that the BD uses, e.g. l3_out_elevated_ukcloud_mgmt"
  default     = null
}

variable "vrf" {
  type        = string
  description = "The name of the vrf that the BD is linked to, e.g. vrf_elevated_ukcloud_mgmt"
}

variable "subnets" {
  type        = list(string)
  description = "The subnets to be added to the BD"
}

variable "access_generic_id" {
  type        = string
  description = "The object ID for the access generic child object of the AEP the EPG should be linked to (refer to the pod module config)"
}

variable "vlan_tag" {
  type        = string
  description = "The VLAN tag to be used for the EPG"
}