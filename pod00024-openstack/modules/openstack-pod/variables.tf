##### Variables

  variable "pod_id" {
    type        = string
    description = "The pod CI number; e.g. pod0001c"
  }

  variable "pod_nodes" {
    type        = list(string)
    description = "List of Node IDs in use for pod; e.g. [101,102]"
  }
