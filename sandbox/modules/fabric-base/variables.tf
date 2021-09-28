variable "spine_nodes" {
  type        = list(string)
  description = "List of Node IDs for the spines in the pod; e.g. [1001,1002]"
}

variable "bgp_as_number" {
  type        = string
  description = "655xx where the last two digits should match the system number; e.g. 65506 (system 6)"
}

variable "ntp_auth_key" {
  type        = string
  description = "Key used for authenticating against NTP servers"
  sensitive   = true
}

variable "inband_mgmt_vlan" {
  type        = number
  description = "VLAN tag for inband mgmt network e.g 10"
}

variable "inband_mgmt_rtr_ids" {
  type = map(any)
}

variable "inband_mgmt_ospf_interface_vlan" {
  type = string
}

variable "inband_mgmt_ospf_interface_list" {
  type = map(object({
    node_id      = number
    interface_id = string
    addr         = string
  }))
}

variable "inband_mgmt_subnet_gateway" {
  type = string
  description = "Gateway address for the inbound mgmt bridge domain"
}

variable "inband_mgmt_node_address" {
  type = map(any)
}