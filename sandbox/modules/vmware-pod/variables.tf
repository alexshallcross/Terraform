variable "pod_id" {
  type        = string
  description = "The pod CI number; e.g. pod0001c"
}

variable "interface_map" {
  type = map(object({
    node_ids   = list(string)
    clnt_ports = list(string)
    mgmt_ports = list(string)
  }))
}