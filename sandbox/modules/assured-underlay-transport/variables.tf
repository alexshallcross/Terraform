variable "assured_underlay_transport_rtr_ids" {
  type = map(any)
}

variable "assured_underlay_transport_ospf_interface_vlan" {
  type = string
}

variable "assured_underlay_transport_ospf_interface_list" {
  type = map(object({
    node_id      = number
    interface_id = string
    addr         = string
  }))
}

variable "assured_underlay_transport_ospf_area_id" {
  type = string
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