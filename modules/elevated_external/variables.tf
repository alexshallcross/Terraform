variable "elevated_external_ospf_interface_vlan" {
  type = string
}

variable "elevated_external_ospf_area_id" {
  type = string
}

variable "elevated_external_ospf" {
  type = map(object({
    router_id = string
    interfaces = list(object({
      interface_id = string
      address      = string
    }))
  }))
}