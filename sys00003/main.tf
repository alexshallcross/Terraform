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

module "pod00035" {
  source = "../modules/vmware_pod_no_vpc"
  pod_id = "pod00035"

  interface_map = {
    leafs_601_602 = {
      node_ids   = [601, 602]
      clnt_ports = [1, 2, 3, 4, 13, 14, 15]
      mgmt_ports = []
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
    "10.44.40.1/25"
  ]
  client_cluster_1_vmotion_subnets = [
    "10.44.43.1/26"
  ]
  client_cluster_1_vmware_subnets = [
    "10.44.42.1/28"
  ]
  client_cluster_1_vxlan_subnets = [
    "10.44.42.129/26"
  ]
  mgmt_cluster_avamar_subnets = [
    "10.44.41.193/26"
  ]
  mgmt_cluster_tools_subnets = [
    "10.44.41.1/26"
  ]
  mgmt_cluster_vmotion_subnets = [
    "10.44.41.65/26"
  ]
  mgmt_cluster_vmware_subnets = [
    "10.44.40.129/25"
  ]
  storage_mgmt_subnets = [
    "10.44.41.129/26"
  ]
  mgmt_vmm_subnets = [
    "10.44.41.65/26"
  ]
  client_avamar_subnets = [
    "10.44.42.193/26"
  ]

  vmm_ci      = "vcv00035i2"
  vmm_host    = "10.44.42.2"
  vmm_svc_acc = "svc_pod00035-vmm@il2management"
}

#########################
#### Imported Config ####
#########################

# tn-skyscape_mgmt

# ap-pod00008_avamar_mgmt

resource "aci_application_epg" "pod00008_avamar_mgmt_protection" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_avamar_mgmt"
  name                   = "pod00008_avamar_mgmt_protection"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_avamar_mgmt_protection"
}

# ap-pod00008_client_cluster1

resource "aci_application_epg" "pod00008_client_cluster1_scaleio_data1" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster1"
  name                   = "pod00008_client_cluster1_scaleio_data1"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster1_scaleio_data1"
}

resource "aci_application_epg" "pod00008_client_cluster1_scaleio_data2" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster1"
  name                   = "pod00008_client_cluster1_scaleio_data2"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster1_scaleio_data2"
}

resource "aci_application_epg" "pod00008_client_cluster1_scaleio_mgmt" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster1"
  name                   = "pod00008_client_cluster1_scaleio_mgmt"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster1_scaleio_mgmt"
}

resource "aci_application_epg" "pod00008_client_cluster1_vmotion" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster1"
  name                   = "pod00008_client_cluster1_vmotion"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster1_vmotion"
}

resource "aci_application_epg" "pod00008_client_cluster1_vmware" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster1"
  name                   = "pod00008_client_cluster1_vmware"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster1_vmware"
}

resource "aci_application_epg" "pod00008_client_cluster1_vxlan" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster1"
  name                   = "pod00008_client_cluster1_vxlan"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster1_vxlan"
}

# ap-pod00008_client_cluster2

resource "aci_application_epg" "pod00008_client_cluster2_scaleio_mgmt" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster2"
  name                   = "pod00008_client_cluster2_scaleio_mgmt"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster2_scaleio_mgmt"
}

resource "aci_application_epg" "pod00008_client_cluster2_vmotion" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster2"
  name                   = "pod00008_client_cluster2_vmotion"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster2_vmotion"
}

resource "aci_application_epg" "pod00008_client_cluster2_vmware" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_client_cluster2"
  name                   = "pod00008_client_cluster2_vmware"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_client_cluster2_vmware"
}

# ap-pod00008_container_transit

resource "aci_application_epg" "pod00008_container_transit" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_container_transit"
  name                   = "pod00008_container_transit"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_container_transit"
}

# ap-pod00008_management

resource "aci_application_epg" "pod00008_cimc" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_cimc"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_cimc"
}

resource "aci_application_epg" "pod00008_mgmt_scaleio_data1" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_scaleio_data1"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_mgmt_scaleio_data1"
}

resource "aci_application_epg" "pod00008_mgmt_scaleio_data2" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_scaleio_data2"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_mgmt_scaleio_data2"
}

resource "aci_application_epg" "pod00008_mgmt_scaleio_mgmt" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_scaleio_mgmt"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_mgmt_scaleio_mgmt"
}

resource "aci_application_epg" "pod00008_mgmt_tools" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_tools"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_mgmt_tools"
}

resource "aci_application_epg" "pod00008_mgmt_vmotion" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_vmotion"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_mgmt_vmotion"
}

resource "aci_application_epg" "pod00008_mgmt_vmware" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_vmware"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/bd-bd_pod00008_mgmt_vmware"
}

# tn-assured_protection

# ap-pod0008_avamar (sic)

resource "aci_application_epg" "pod00008_client_avamar" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod0008_avamar"
  name                   = "pod00008_client_avamar"
  relation_fv_rs_bd      = "uni/tn-assured_protection/bd-bd_pod00008_client_avamar"
}

# ap-pod00008_zerto

resource "aci_application_epg" "pod00008_client_zcc" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod00008_zerto"
  name                   = "pod00008_client_zcc"
  relation_fv_rs_bd      = "uni/tn-assured_protection/bd-bd_pod00008_client_zcc"
}

resource "aci_application_epg" "pod00008_client_zvra" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod00008_zerto"
  name                   = "pod00008_client_zvra"
  relation_fv_rs_bd      = "uni/tn-assured_protection/bd-bd_pod00008_client_zvra"
}

resource "aci_application_epg" "pod00008_mgmt_zvm" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod00008_zerto"
  name                   = "pod00008_mgmt_zvm"
  relation_fv_rs_bd      = "uni/tn-assured_protection/bd-bd_pod00008_mgmt_zvm"
}