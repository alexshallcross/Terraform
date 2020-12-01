variable "openstack_pods" {
    type = map(object({
        pod_id = string
        pod_nodes = list(string)
    }))
}