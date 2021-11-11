variable "internet_ospf_interface_vlan" {
  type = string
}

variable "internet_ospf_area_id" {
  type = string
}

variable "internet_ospf" {
  type = map(object({
    router_id = string
    interfaces = list(object({
      interface_id = string
      address      = string
    }))
  }))
}

variable "interface_speed_policy" {
  type = string
}

variable "interface_cdp_policy" {
  type = string
}

variable "interface_lldp_policy" {
  type = string
}