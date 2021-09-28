variable "elevated_ukcloud_mgmt_rtr_ids" {
  type = map(any)
}

variable "elevated_ukcloud_mgmt_ospf_interface_vlan" {
  type = string
}

variable "elevated_ukcloud_mgmt_ospf_interface_list" {
  type = map(object({
    node_id      = number
    interface_id = string
    addr         = string
  }))
}

variable "elevated_ukcloud_mgmt_ospf_area_id" {
  type = string
}