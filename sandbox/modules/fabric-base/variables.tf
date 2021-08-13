variable "spine_nodes" {
  type        = list(string)
  description = "List of Node IDs for the spines in the pod; e.g. [1001,1002]"
}

variable "bgp_as_number" {
  type        = string
  description = "655xx where the last two digits should match the system number; e.g. system 6 would be 65506"
}

variable "ntp_auth_key" {
  type        = string
  description = "Key used for authenticating against NTP servers"
  sensitive   = true
}