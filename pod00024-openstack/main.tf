##### APIC Login

  provider "aci" {
    username = "admin"
    password = "ciscopsdt"
    url      = "https://sandboxapicdc.cisco.com"
    insecure = false
  }

##### Resources

### Application Profiles

  # openstack

    resource "aci_application_profile" "openstack" {
      tenant_dn = "uni/tn-skyscape_mgmt"
      name      = "pod00024_openstack"
    }

    ### EPGs 

      # internal_api

        resource "aci_application_epg" "internal_api" {
          application_profile_dn = aci_application_profile.openstack.id
          name                   = "pod00024_internal_api"
          relation_fv_rs_bd      = aci_bridge_domain.internal_api.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }

          resource "aci_epg_to_domain" "internal_api" {
            application_epg_dn = aci_application_epg.internal_api.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

      # ipmi

        resource "aci_application_epg" "ipmi" {
          application_profile_dn = aci_application_profile.openstack.id
          name                   = "pod00024_ipmi"
          relation_fv_rs_bd      = aci_bridge_domain.ipmi.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }
        
          resource "aci_epg_to_domain" "ipmi" {
            application_epg_dn = aci_application_epg.ipmi.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

      # mgmt

        resource "aci_application_epg" "mgmt" {
          application_profile_dn = aci_application_profile.openstack.id
          name                   = "pod00024_mgmt"
          relation_fv_rs_bd      = aci_bridge_domain.mgmt.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }
        
          resource "aci_epg_to_domain" "mgmt" {
            application_epg_dn = aci_application_epg.mgmt.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }
      
      # mgmt_provisioning

        resource "aci_application_epg" "mgmt_provisioning" {
          application_profile_dn = aci_application_profile.openstack.id
          name                   = "pod00024_mgmt_provisioning"
          relation_fv_rs_bd      = aci_bridge_domain.mgmt_provisioning.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }
        
          resource "aci_epg_to_domain" "mgmt_provisioning" {
            application_epg_dn = aci_application_epg.mgmt_provisioning.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

      # storage

        resource "aci_application_epg" "storage" {
          application_profile_dn = aci_application_profile.openstack.id
          name                   = "pod00024_storage"
          relation_fv_rs_bd      = aci_bridge_domain.storage.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }
        
          resource "aci_epg_to_domain" "storage" {
            application_epg_dn = aci_application_epg.storage.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

      # storage_mgmt

        resource "aci_application_epg" "storage_mgmt" {
          application_profile_dn = aci_application_profile.openstack.id
          name                   = "pod00024_storage_mgmt"
          relation_fv_rs_bd      = aci_bridge_domain.storage_mgmt.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }
        
          resource "aci_epg_to_domain" "storage_mgmt" {
            application_epg_dn = aci_application_epg.storage_mgmt.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

      # tenant

        resource "aci_application_epg" "tenant" {
          application_profile_dn = aci_application_profile.openstack.id
          name                   = "pod00024_tenant"
          relation_fv_rs_bd      = aci_bridge_domain.tenant.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }
        
          resource "aci_epg_to_domain" "tenant" {
            application_epg_dn = aci_application_epg.tenant.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

  # internet_tenants

    resource "aci_application_profile" "internet_tenants" {
      tenant_dn = "uni/internet"
      name      = "pod00024_internet_tenants"
    }

    ### EPGs 

      # mgmt_openstack

        resource "aci_application_epg" "mgmt_openstack" {
          application_profile_dn = aci_application_profile.internet_tenants.id
          name                   = "pod00024_mgmt_openstack"
          relation_fv_rs_bd      = aci_bridge_domain.mgmt_openstack.id
          relation_fv_rs_prov    = [
            "uni/tn-internet/brc-ukcloud_openstack_mgmt_internet_in",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-internet/brc-ukcloud_openstack_mgmt_internet_out",
            "uni/tn-internet/brc-ukcloud_object_storage_internet_in",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }

          resource "aci_epg_to_domain" "mgmt_openstack" {
            application_epg_dn = aci_application_epg.mgmt_openstack.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

      # nti0007ei2

        resource "aci_application_epg" "nti0007ei2" {
          application_profile_dn = aci_application_profile.internet_tenants.id
          name                   = "pod00024_nti0007ei2"
          relation_fv_rs_bd      = aci_bridge_domain.nti0007ei2.id
          relation_fv_rs_prov    = [
            "uni/tn-common/brc-default",
            ]
          relation_fv_rs_cons    = [
            "uni/tn-common/brc-default",
            "uni/tn-internet/brc-ukcloud_openstack_mgmt_internet_out",
            "uni/tn-internet/brc-ukcloud_object_storage_internet_in",
            ]
          lifecycle {
            ignore_changes = [
              relation_fv_rs_graph_def,
            ]
          }
        }

          resource "aci_epg_to_domain" "nti0007ei2" {
            application_epg_dn = aci_application_epg.nti0007ei2.id
            tdn                = "uni/phys-phys_domain_openstack_pod00024"
          }

### Bridge Domains

  resource "aci_bridge_domain" "internal_api" {
    tenant_dn                = "uni/tn-skyscape_mgmt"
    name                     = "bd_pod00024_openstack_internal_api"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt",
      ]
    relation_fv_rs_ctx       = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"
  }

    resource "aci_subnet" "internal_api" {
      parent_dn = aci_bridge_domain.internal_api.id
      ip        = "10.41.190.1/23"
      scope     = [
        "shared",
        ]
    }
  
  resource "aci_bridge_domain" "ipmi" {
    tenant_dn                = "uni/tn-skyscape_mgmt"
    name                     = "bd_pod00024_openstack_ipmi"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt",
      ]
    relation_fv_rs_ctx       = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"
  }

    resource "aci_subnet" "ipmi" {
      parent_dn = aci_bridge_domain.ipmi.id
      ip        = "10.41.184.1/23"
      scope     = [
        "shared",
        ]
    }

  resource "aci_bridge_domain" "mgmt" {
    tenant_dn                = "uni/tn-skyscape_mgmt"
    name                     = "bd_pod00024_openstack_mgmt"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt",
      ]
    relation_fv_rs_ctx       = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"
  }

    resource "aci_subnet" "mgmt" {
      parent_dn = aci_bridge_domain.mgmt.id
      ip        = "10.41.186.1/23"
      scope     = [
        "shared",
        ]
    }

  resource "aci_bridge_domain" "mgmt_provisioning" {
    tenant_dn                = "uni/tn-skyscape_mgmt"
    name                     = "bd_pod00024_openstack_mgmt_provisioning"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt",
      ]
    relation_fv_rs_ctx       = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"
  }

    resource "aci_subnet" "mgmt_provisioning" {
      parent_dn = aci_bridge_domain.mgmt_provisioning.id
      ip        = "10.41.188.1/23"
      scope     = [
        "shared",
        ]
    }

  resource "aci_bridge_domain" "storage" {
    tenant_dn                = "uni/tn-skyscape_mgmt"
    name                     = "bd_pod00024_openstack_storage"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt",
      ]
    relation_fv_rs_ctx       = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"
  }

    resource "aci_subnet" "storage" {
      parent_dn = aci_bridge_domain.storage.id
      ip        = "10.41.194.1/23"
      scope     = [
        "shared",
        ]
    }

  resource "aci_bridge_domain" "storage_mgmt" {
    tenant_dn                = "uni/tn-skyscape_mgmt"
    name                     = "bd_pod00024_openstack_storage_mgmt"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt",
      ]
    relation_fv_rs_ctx       = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"
  }

    resource "aci_subnet" "storage_mgmt" {
      parent_dn = aci_bridge_domain.storage_mgmt.id
      ip        = "10.41.196.1/23"
      scope     = [
        "shared",
        ]
    }

  resource "aci_bridge_domain" "tenant" {
    tenant_dn                = "uni/tn-skyscape_mgmt"
    name                     = "bd_pod00024_openstack_tenant"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = ["uni/tn-skyscape_mgmt/out-l3_out_skyscape_mgmt",]
    relation_fv_rs_ctx       = "uni/tn-skyscape_mgmt/ctx-vrf_skyscape_mgmt"
  }

    resource "aci_subnet" "tenant" {
      parent_dn = aci_bridge_domain.tenant.id
      ip        = "10.41.192.1/23"
      scope     = [
        "shared",
        ]
    }

  resource "aci_bridge_domain" "mgmt_openstack" {
    tenant_dn                = "uni/tn-internet"
    name                     = "bd_pod00024_mgmt_tenant"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-internet/out-l3_out_internet",
      ]
    relation_fv_rs_ctx       = "uni/tn-internet/ctx-vrf_internet"
  }

    resource "aci_subnet" "mgmt_openstack" {
      parent_dn = aci_bridge_domain.mgmt_openstack.id
      ip        = "51.179.217.33/28"
      scope     = [
        "shared",
        ]
    }

  resource "aci_bridge_domain" "nti0007ei2" {
    tenant_dn                = "uni/tn-internet"
    name                     = "bd_pod00024_mgmt_tenant"
    ep_move_detect_mode      = "garp"
    relation_fv_rs_bd_to_out = [
      "uni/tn-internet/out-l3_out_internet",
      ]
    relation_fv_rs_ctx       = "uni/tn-internet/ctx-vrf_internet"
  }

    resource "aci_subnet" "nti0007ei2" {
      parent_dn = aci_bridge_domain.nti0007ei2.id
      ip        = "51.179.217.65/26"
      scope     = [
        "shared",
        ]
    }

### Switch Profiles

  resource "aci_leaf_profile" "openstack" {
    name        = "openstack_pod00024_profile"
    leaf_selector {
      name                    = "openstack_pod00024_switch_selector"
      switch_association_type = "range"
      node_block {
        name  = "f0327654421197"
        from_ = "401"
        to_   = "402"
      }
    }
    relation_infra_rs_acc_port_p = [
      aci_leaf_interface_profile.port_1.id,
      aci_leaf_interface_profile.port_2.id,
      aci_leaf_interface_profile.port_3.id,
      aci_leaf_interface_profile.port_4.id,
      aci_leaf_interface_profile.port_5.id,
      aci_leaf_interface_profile.port_6.id,
      aci_leaf_interface_profile.port_7.id,
      aci_leaf_interface_profile.port_8.id,
      aci_leaf_interface_profile.port_9.id,
      aci_leaf_interface_profile.port_10.id,
      aci_leaf_interface_profile.port_11.id,
      aci_leaf_interface_profile.port_12.id,
      aci_leaf_interface_profile.port_13.id,
      aci_leaf_interface_profile.port_14.id,
      aci_leaf_interface_profile.port_15.id,
      aci_leaf_interface_profile.port_16.id,
      aci_leaf_interface_profile.port_17.id,
      aci_leaf_interface_profile.port_18.id,
      aci_leaf_interface_profile.port_19.id,
      aci_leaf_interface_profile.port_20.id,
      aci_leaf_interface_profile.port_21.id,
      aci_leaf_interface_profile.port_22.id,
      aci_leaf_interface_profile.port_23.id,
      aci_leaf_interface_profile.port_24.id,
      aci_leaf_interface_profile.port_25.id,
    ]
  }

### Interface Profiles

  # Port 1

  resource "aci_leaf_interface_profile" "port_1" {
    name = "pod00024_openstack_port_1"
  }

    resource "aci_access_port_selector" "port_1" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_1.id
      name                           = "Port-1"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_1" {
        access_port_selector_dn = aci_access_port_selector.port_1.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "1"
        to_card                 = "1"
        to_port                 = "1"
      }

  # Port 2

  resource "aci_leaf_interface_profile" "port_2" {
    name = "pod00024_openstack_port_2"
  }

    resource "aci_access_port_selector" "port_2" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_2.id
      name                           = "Port-2"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_2" {
        access_port_selector_dn = aci_access_port_selector.port_2.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "2"
        to_card                 = "1"
        to_port                 = "2"
      }

  # Port 3

  resource "aci_leaf_interface_profile" "port_3" {
    name = "pod00024_openstack_port_3"
  }

    resource "aci_access_port_selector" "port_3" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_3.id
      name                           = "Port-3"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_3" {
        access_port_selector_dn = aci_access_port_selector.port_3.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "3"
        to_card                 = "1"
        to_port                 = "3"
      }

  # Port 4

  resource "aci_leaf_interface_profile" "port_4" {
    name = "pod00024_openstack_port_4"
  }

    resource "aci_access_port_selector" "port_4" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_4.id
      name                           = "Port-4"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_4" {
        access_port_selector_dn = aci_access_port_selector.port_4.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "4"
        to_card                 = "1"
        to_port                 = "4"
      }

  # Port 5

  resource "aci_leaf_interface_profile" "port_5" {
    name = "pod00024_openstack_port_5"
  }

    resource "aci_access_port_selector" "port_5" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_5.id
      name                           = "Port-5"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_5" {
        access_port_selector_dn = aci_access_port_selector.port_5.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "5"
        to_card                 = "1"
        to_port                 = "5"
      }

  # Port 6

  resource "aci_leaf_interface_profile" "port_6" {
    name = "pod00024_openstack_port_6"
  }

    resource "aci_access_port_selector" "port_6" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_6.id
      name                           = "Port-6"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_6" {
        access_port_selector_dn = aci_access_port_selector.port_6.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "6"
        to_card                 = "1"
        to_port                 = "6"
      }

  # Port 7

  resource "aci_leaf_interface_profile" "port_7" {
    name = "pod00024_openstack_port_7"
  }

    resource "aci_access_port_selector" "port_7" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_7.id
      name                           = "Port-7"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_7" {
        access_port_selector_dn = aci_access_port_selector.port_7.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "7"
        to_card                 = "1"
        to_port                 = "7"
      }

  # Port 8

  resource "aci_leaf_interface_profile" "port_8" {
    name = "pod00024_openstack_port_8"
  }

    resource "aci_access_port_selector" "port_8" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_8.id
      name                           = "Port-8"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_8" {
        access_port_selector_dn = aci_access_port_selector.port_8.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "8"
        to_card                 = "1"
        to_port                 = "8"
      }

  # Port 9

  resource "aci_leaf_interface_profile" "port_9" {
    name = "pod00024_openstack_port_9"
  }

    resource "aci_access_port_selector" "port_9" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_9.id
      name                           = "Port-9"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_9" {
        access_port_selector_dn = aci_access_port_selector.port_9.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "9"
        to_card                 = "1"
        to_port                 = "9"
      }

  # Port 10

  resource "aci_leaf_interface_profile" "port_10" {
    name = "pod00024_openstack_port_10"
  }

    resource "aci_access_port_selector" "port_10" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_10.id
      name                           = "Port-10"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_10" {
        access_port_selector_dn = aci_access_port_selector.port_10.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "10"
        to_card                 = "1"
        to_port                 = "10"
      }

  # Port 11

  resource "aci_leaf_interface_profile" "port_11" {
    name = "pod00024_openstack_port_11"
  }

    resource "aci_access_port_selector" "port_11" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_11.id
      name                           = "Port-11"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_11" {
        access_port_selector_dn = aci_access_port_selector.port_11.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "11"
        to_card                 = "1"
        to_port                 = "11"
      }

  # Port 12

  resource "aci_leaf_interface_profile" "port_12" {
    name = "pod00024_openstack_port_12"
  }

    resource "aci_access_port_selector" "port_12" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_12.id
      name                           = "Port-12"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_12" {
        access_port_selector_dn = aci_access_port_selector.port_12.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "12"
        to_card                 = "1"
        to_port                 = "12"
      }

  # Port 13

  resource "aci_leaf_interface_profile" "port_13" {
    name = "pod00024_openstack_port_13"
  }

    resource "aci_access_port_selector" "port_13" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_13.id
      name                           = "Port-13"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_13" {
        access_port_selector_dn = aci_access_port_selector.port_13.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "13"
        to_card                 = "1"
        to_port                 = "13"
      }
  
  # Port 14

  resource "aci_leaf_interface_profile" "port_14" {
    name = "pod00024_openstack_port_14"
  }

    resource "aci_access_port_selector" "port_14" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_14.id
      name                           = "Port-14"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_14" {
        access_port_selector_dn = aci_access_port_selector.port_14.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "14"
        to_card                 = "1"
        to_port                 = "14"
      }

  # Port 15

  resource "aci_leaf_interface_profile" "port_15" {
    name = "pod00024_openstack_port_15"
  }

    resource "aci_access_port_selector" "port_15" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_15.id
      name                           = "Port-15"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_15" {
        access_port_selector_dn = aci_access_port_selector.port_15.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "15"
        to_card                 = "1"
        to_port                 = "15"
      }

  # Port 16

  resource "aci_leaf_interface_profile" "port_16" {
    name = "pod00024_openstack_port_16"
  }

    resource "aci_access_port_selector" "port_16" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_16.id
      name                           = "Port-16"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_16" {
        access_port_selector_dn = aci_access_port_selector.port_16.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "16"
        to_card                 = "1"
        to_port                 = "16"
      }

  # Port 17

  resource "aci_leaf_interface_profile" "port_17" {
    name = "pod00024_openstack_port_17"
  }

    resource "aci_access_port_selector" "port_17" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_17.id
      name                           = "Port-17"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_17" {
        access_port_selector_dn = aci_access_port_selector.port_17.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "17"
        to_card                 = "1"
        to_port                 = "17"
      }

  # Port 18

  resource "aci_leaf_interface_profile" "port_18" {
    name = "pod00024_openstack_port_18"
  }

    resource "aci_access_port_selector" "port_18" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_18.id
      name                           = "Port-18"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_18" {
        access_port_selector_dn = aci_access_port_selector.port_18.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "18"
        to_card                 = "1"
        to_port                 = "18"
      }

  # Port 19

  resource "aci_leaf_interface_profile" "port_19" {
    name = "pod00024_openstack_port_19"
  }

    resource "aci_access_port_selector" "port_19" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_19.id
      name                           = "Port-19"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_19" {
        access_port_selector_dn = aci_access_port_selector.port_19.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "19"
        to_card                 = "1"
        to_port                 = "19"
      }

  # Port 20

  resource "aci_leaf_interface_profile" "port_20" {
    name = "pod00024_openstack_port_20"
  }

    resource "aci_access_port_selector" "port_20" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_20.id
      name                           = "Port-20"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_20" {
        access_port_selector_dn = aci_access_port_selector.port_20.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "20"
        to_card                 = "1"
        to_port                 = "20"
      }
  
  # Port 21

  resource "aci_leaf_interface_profile" "port_21" {
    name = "pod00024_openstack_port_21"
  }

    resource "aci_access_port_selector" "port_21" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_21.id
      name                           = "Port-21"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_21" {
        access_port_selector_dn = aci_access_port_selector.port_21.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "21"
        to_card                 = "1"
        to_port                 = "21"
      }

  # Port 22

  resource "aci_leaf_interface_profile" "port_22" {
    name = "pod00024_openstack_port_22"
  }

    resource "aci_access_port_selector" "port_22" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_22.id
      name                           = "Port-22"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_22" {
        access_port_selector_dn = aci_access_port_selector.port_22.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "22"
        to_card                 = "1"
        to_port                 = "22"
      }

  # Port 23

  resource "aci_leaf_interface_profile" "port_23" {
    name = "pod00024_openstack_port_23"
  }

    resource "aci_access_port_selector" "port_23" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_23.id
      name                           = "Port-23"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_23" {
        access_port_selector_dn = aci_access_port_selector.port_23.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "23"
        to_card                 = "1"
        to_port                 = "23"
      }

  # Port 24

  resource "aci_leaf_interface_profile" "port_24" {
    name = "pod00024_openstack_port_24"
  }

    resource "aci_access_port_selector" "port_24" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_24.id
      name                           = "Port-24"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_24" {
        access_port_selector_dn = aci_access_port_selector.port_24.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "24"
        to_card                 = "1"
        to_port                 = "24"
      }

  # Port 25

  resource "aci_leaf_interface_profile" "port_25" {
    name = "pod00024_openstack_port_25"
  }

    resource "aci_access_port_selector" "port_25" {
      leaf_interface_profile_dn      = aci_leaf_interface_profile.port_25.id
      name                           = "Port-25"
      access_port_selector_type      = "range"
      relation_infra_rs_acc_base_grp = "uni/infra/funcprof/accportgrp-pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    }

      resource "aci_access_port_block" "port_25" {
        access_port_selector_dn = aci_access_port_selector.port_25.id
        name                    = "block2"
        from_card               = "1"
        from_port               = "25"
        to_card                 = "1"
        to_port                 = "25"
      }

### Leaf Interface Policy Group

  resource "aci_leaf_access_port_policy_group" "openstack" {
    name                          = "pol_grp_40G_cdp_lldp_openstack_hosts_pod00024"
    relation_infra_rs_h_if_pol    = "uni/infra/hintfpol-40G"
    relation_infra_rs_cdp_if_pol  = "uni/infra/cdpIfP-cdp_enabled"
    relation_infra_rs_lldp_if_pol = "uni/infra/lldpIfP-lldp_enabled"
    relation_infra_rs_att_ent_p   = "uni/infra/attentp-aep_openstack_pod00024"
  } 

### Attachable Entity Profile

  resource "aci_attachable_access_entity_profile" "openstack" {
    name                    = "aep_openstack_pod00024"
    relation_infra_rs_dom_p = [
      "uni/phys-phys_domain_openstack_pod00024"
      ]
    }

    resource "aci_access_generic" "openstack" {
      attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.openstack.id
      name                                = "default"
    }

      resource "aci_epgs_using_function" "internal_api" {
        access_generic_dn = aci_access_generic.openstack.id
        tdn               = aci_application_epg.internal_api.id
        encap             = "vlan-103"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      resource "aci_epgs_using_function" "ipmi" {
        access_generic_dn = aci_access_generic.openstack.id
        tdn               = aci_application_epg.ipmi.id
        encap             = "vlan-100"
        instr_imedcy      = "lazy"
        mode              = "native"
      }

      resource "aci_epgs_using_function" "mgmt" {
        access_generic_dn = aci_access_generic.openstack.id
        tdn               = aci_application_epg.mgmt.id
        encap             = "vlan-101"
        instr_imedcy      = "lazy"
        mode              = "regular"
      }

      resource "aci_epgs_using_function" "mgmt_provisioning" {
        access_generic_dn = aci_access_generic.openstack.id
        tdn               = aci_application_epg.mgmt_provisioning.id
        encap             = "vlan-102"
        instr_imedcy      = "lazy"
        mode              = "regular"
      }

      resource "aci_epgs_using_function" "storage" {
        access_generic_dn = aci_access_generic.openstack.id
        tdn               = aci_application_epg.storage.id
        encap             = "vlan-105"
        instr_imedcy      = "lazy"
        mode              = "regular"
      }

      resource "aci_epgs_using_function" "storage_mgmt" {
        access_generic_dn = aci_access_generic.openstack.id
        tdn               = aci_application_epg.storage_mgmt.id
        encap             = "vlan-106"
        instr_imedcy      = "lazy"
        mode              = "regular"
      }

      resource "aci_epgs_using_function" "tenant" {
        access_generic_dn = aci_access_generic.openstack.id
        tdn               = aci_application_epg.tenant.id
        encap             = "vlan-104"
        instr_imedcy      = "lazy"
        mode              = "regular"
      }

### VLAN Pool

  resource "aci_vlan_pool" "openstack" {
    name       = "vlan_static_pod00024"
    alloc_mode = "static"
  }

    resource "aci_ranges" "openstack_range1" {
      vlan_pool_dn = aci_vlan_pool.openstack.id
      _from        = "vlan-100"
      to           = "vlan-199"
      alloc_mode   = "static"
      role         = "external"
    }

    resource "aci_ranges" "openstack_range2" {
      vlan_pool_dn = aci_vlan_pool.openstack.id
      _from        = "vlan-201"
      to           = "vlan-202"
      alloc_mode   = "static"
      role         = "external"
    }

    resource "aci_ranges" "openstack_range3" {
      vlan_pool_dn = aci_vlan_pool.openstack.id
      _from        = "vlan-1000"
      to           = "vlan-1999"
      alloc_mode   = "static"
      role         = "external"
    }

### Physical Domains

  resource "aci_physical_domain" "openstack" {
    name                      = "phys_domain_openstack_pod00024"
    relation_infra_rs_vlan_ns = aci_vlan_pool.openstack.id
  }