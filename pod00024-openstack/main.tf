##### APIC Login

  provider "aci" {
    username = "admin"
    password = "ciscopsdt"
    url      = "https://sandboxapicdc.cisco.com"
    insecure = false
  }

##### Modules

module "pod00024-openstack" {
  source    = "./modules/openstack-pod"
  pod_id    = "pod00024"
  pod_nodes = [401,402]
}