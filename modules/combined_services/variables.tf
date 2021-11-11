variable "assured_combined_services_bgp_interface_vlan" {
  type = string
}

variable "elevated_combined_services_bgp_interface_vlan" {
  type = string
}

variable "assured_combined_services_bgp" {
  type = map(object({
    router_id = string
    interfaces = list(object({
      interface_id  = string
      address       = string
      bgp_peer      = string
      bgp_asn       = number
      bgp_local_asn = number
    }))
  }))
}

variable "elevated_combined_services_bgp" {
  type = map(object({
    router_id = string
    interfaces = list(object({
      interface_id  = string
      address       = string
      bgp_peer      = string
      bgp_asn       = number
      bgp_local_asn = number
    }))
  }))
}