variable "elevated_ukcloud_mgmt_ospf_interface_vlan" {
  type = string
}

variable "elevated_ukcloud_mgmt_ospf_area_id" {
  type = string
}

variable "elevated_ukcloud_mgmt_ospf" {
  type = map(object({
    router_id  = string
    interfaces = list(object({
      interface_id = string
      address      = string
    }))
  }))
}