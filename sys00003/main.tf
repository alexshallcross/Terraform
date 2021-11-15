############################
#### Statefile Location ####
############################

terraform {
  backend "local" {
    path = "S:/Networks/Terraform/statefiles/sys00003.tfstate"
  }
}

####################
#### APIC Login ####
####################

provider "aci" {
  username = var.a_username
  password = var.b_password
  url      = "https://asc.sys00003.il2management.local"
  insecure = true
}

#################
#### Modules ####
#################

module "pod00034" {
  source = "../modules/vmware_pod"
  pod_id = "pod00034"

  interface_map = {
    leafs_601_602 = {
      node_ids   = [601, 602]
      clnt_ports = [1, 2, 3, 4]
      mgmt_ports = [11, 12]
      cimc_ports = []
    }
  }

  ukcloud_mgmt_tenant = "uni/tn-skyscape_mgmt"
  ukcloud_mgmt_l3_out = "uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt"
  ukcloud_mgmt_vrf    = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"

  protection_tenant = "uni/tn-assured_protection"
  protection_l3_out = "uni/tn-assured_protection/out-l3_out_vrf_assured_protection"
  protection_vrf    = "uni/tn-assured_protection/ctx-vrf_assured_protection"

  cimc_subnets = [
    "10.44.32.1/25"
  ]
  client_cluster_1_vmotion_subnets = [
    "10.44.35.1/26"
  ]
  client_cluster_1_vmware_subnets = [
    "10.44.34.1/28"
  ]
  client_cluster_1_vxlan_subnets = [
    "10.44.34.129/26"
  ]
  mgmt_cluster_avamar_subnets = [
    "10.44.33.193/26"
  ]
  mgmt_cluster_tools_subnets = [
    "10.44.33.1/26"
  ]
  mgmt_cluster_vmotion_subnets = [
    "10.44.33.65/26"
  ]
  mgmt_cluster_vmware_subnets = [
    "10.44.32.129/25"
  ]
  storage_mgmt_subnets = [
    "10.44.33.129/26"
  ]
  mgmt_vmm_subnets = [
    "10.44.33.65/26"
  ]
  client_avamar_subnets = [
    "10.44.34.193/26"
  ]

  vmm_ci      = "vcv00033i2"
  vmm_host    = "10.44.34.2"
  vmm_svc_acc = "svc_pod00034-vmm@il2management"
}