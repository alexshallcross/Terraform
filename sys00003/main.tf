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

## Tenant - skyscape_mgmt

## Application Profile - pod00008_avamar_mgmt

resource "aci_application_profile" "pod00008_avamar_mgmt" {
  tenant_dn = "uni/tn-skyscape_mgmt"
  name      = "pod00008_avamar_mgmt"
}

## EPGs in Application Profile - pod00008_avamar_mgmt

resource "aci_application_epg" "pod00008_avamar_mgmt_protection" {
  application_profile_dn = aci_application_profile.pod00008_avamar_mgmt.id
  name                   = "pod00008_avamar_mgmt_protection"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_avamar_mgmt_protection"
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

## Application Profile - pod00008_client_cluster1

resource "aci_application_profile" "pod00008_client_cluster1" {
  tenant_dn = "uni/tn-skyscape_mgmt"
  name      = "pod00008_client_cluster1"
}

## EPGs in Application Profile - pod00008_client_cluster1

resource "aci_application_epg" "pod00008_client_cluster1_scaleio_data1" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster1.id
  name                   = "pod00008_client_cluster1_scaleio_data1"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster1_scaleio_data1"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_cluster1_scaleio_data2" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster1.id
  name                   = "pod00008_client_cluster1_scaleio_data2"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster1_scaleio_data2"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_cluster1_scaleio_mgmt" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster1.id
  name                   = "pod00008_client_cluster1_scaleio_mgmt"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster1_scaleio_mgmt"
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_cluster1_vmotion" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster1.id
  name                   = "pod00008_client_cluster1_vmotion"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster1_vmotion"
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_cluster1_vmware" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster1.id
  name                   = "pod00008_client_cluster1_vmware"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster1_vmware"
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_cluster1_vxlan" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster1.id
  name                   = "pod00008_client_cluster1_vxlan"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster1_vxlan"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

## Application Profile - pod00008_client_cluster2

resource "aci_application_profile" "pod00008_client_cluster2" {
  tenant_dn = "uni/tn-skyscape_mgmt"
  name      = "pod00008_client_cluster2"
}

## EPGs in Application Profile - pod00008_client_cluster2

resource "aci_application_epg" "pod00008_client_cluster2_scaleio_mgmt" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster2.id
  name                   = "pod00008_client_cluster2_scaleio_mgmt"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster2_scaleio_mgmt"
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_cluster2_vmotion" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster2.id
  name                   = "pod00008_client_cluster2_vmotion"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster2_vmotion"
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_cluster2_vmware" {
  application_profile_dn = aci_application_profile.pod00008_client_cluster2.id
  name                   = "pod00008_client_cluster2_vmware"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_client_cluster2_vmware"
  relation_fv_rs_prov = [
    "uni/tn-common/brc-default",
  ]
  relation_fv_rs_cons = [
    "uni/tn-common/brc-default",
  ]
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

# ap-pod00008_container_transit

resource "aci_application_epg" "pod00008_container_transit" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_container_transit"
  name                   = "pod00008_container_transit"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_container_transit"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

# ap-pod00008_management

resource "aci_application_epg" "pod00008_cimc" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_cimc"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_cimc"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_mgmt_scaleio_data1" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_scaleio_data1"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_mgmt_scaleio_data1"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_mgmt_scaleio_data2" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_scaleio_data2"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_mgmt_scaleio_data2"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_mgmt_scaleio_mgmt" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_scaleio_mgmt"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_mgmt_scaleio_mgmt"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_mgmt_tools" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_tools"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_mgmt_tools"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_mgmt_vmotion" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_vmotion"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_mgmt_vmotion"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_mgmt_vmware" {
  application_profile_dn = "uni/tn-skyscape_mgmt/ap-pod00008_management"
  name                   = "pod00008_mgmt_vmware"
  relation_fv_rs_bd      = "uni/tn-skyscape_mgmt/BD-bd_pod00008_mgmt_vmware"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

# tn-assured_protection

# ap-pod0008_avamar (sic)

resource "aci_application_epg" "pod00008_client_avamar" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod0008_avamar"
  name                   = "pod00008_client_avamar"
  relation_fv_rs_bd      = "uni/tn-assured_protection/BD-bd_pod00008_client_avamar"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

# ap-pod00008_zerto

resource "aci_application_epg" "pod00008_client_zcc" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod00008_zerto"
  name                   = "pod00008_client_zcc"
  relation_fv_rs_bd      = "uni/tn-assured_protection/BD-bd_pod00008_client_zcc"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_client_zvra" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod00008_zerto"
  name                   = "pod00008_client_zvra"
  relation_fv_rs_bd      = "uni/tn-assured_protection/BD-bd_pod00008_client_zvra"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_mgmt_zvm" {
  application_profile_dn = "uni/tn-assured_protection/ap-pod00008_zerto"
  name                   = "pod00008_mgmt_zvm"
  relation_fv_rs_bd      = "uni/tn-assured_protection/BD-bd_pod00008_mgmt_zvm"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}


# tn-internet

# ap-pod00008_internet_tenants

resource "aci_application_epg" "pod00008_mgmt_vmware_internet" {
  application_profile_dn = "uni/tn-internet/ap-pod00008_internet_tenants"
  name                   = "pod00008_mgmt_vmware"
  relation_fv_rs_bd      = "uni/tn-internet/BD-bd_pod00008_mgmt_vmware"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_nti00009i2" {
  application_profile_dn = "uni/tn-internet/ap-pod00008_internet_tenants"
  name                   = "pod00008_nti00009i2"
  relation_fv_rs_bd      = "uni/tn-internet/BD-bd_pod00008_nti00009i2"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_nti00219i2" {
  application_profile_dn = "uni/tn-internet/ap-pod00008_internet_tenants"
  name                   = "pod00008_nti00219i2"
  relation_fv_rs_bd      = "uni/tn-internet/BD-bd_pod00008_nti00219i2"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_nti00241i2" {
  application_profile_dn = "uni/tn-internet/ap-pod00008_internet_tenants"
  name                   = "pod00008_nti00241i2"
  relation_fv_rs_bd      = "uni/tn-internet/BD-bd_pod00008_nti00241i2"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_nti00242i2" {
  application_profile_dn = "uni/tn-internet/ap-pod00008_internet_tenants"
  name                   = "pod00008_nti00242i2"
  relation_fv_rs_bd      = "uni/tn-internet/BD-bd_pod00008_nti00242i2"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_t0_internet_provider_transit" {
  application_profile_dn = "uni/tn-internet/ap-pod00008_internet_tenants"
  name                   = "pod00008_t0_internet_provider_transit"
  relation_fv_rs_bd      = "uni/tn-internet/BD-bd_pod00008_t0_internet_provider_transit"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}

resource "aci_application_epg" "pod00008_t0_transit_epg1" {
  application_profile_dn = "uni/tn-internet/ap-pod00008_internet_tenants"
  name                   = "pod00008_t0_transit_epg1"
  relation_fv_rs_bd      = "uni/tn-internet/BD-bd_pod00008_t0_transit_epg1"
  lifecycle {
    ignore_changes = [
      relation_fv_rs_graph_def,
    ]
  }
}