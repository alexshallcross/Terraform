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
  type = string
  default = "40G"
  description = "The name of the Link Level Policy to use."
}

variable "cdp_policy" {
  type = string
  default = "cdp_enabled"
  description = "The name of the CDP Interface Policy to use."
}

variable "lldp_policy" {
  type = string
  default = "lldp_enabled"
  description = "The name of the LLDP Interface Policy to use."
}