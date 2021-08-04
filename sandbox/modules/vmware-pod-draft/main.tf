#### Fabric Access Policies ####
  # All configuration to be created under fabric access policies

  ### Resources
    

    ### Physical Domains

      resource "aci_physical_domain" "vmware" {
        name                      = join("", [var.pod_id, "_vmware"])
        relation_infra_rs_vlan_ns = aci_vlan_pool.vmware.id
      }

    ### VLAN Pools

      resource "aci_vlan_pool" "vmware_static" {
        name       = join("", [var.pod_id, "_vmware_static"])
        alloc_mode = "static"
      }

      resource "aci_ranges" "vmware_static_range1" {
        vlan_pool_dn = aci_vlan_pool.vmware_static.id
        from         = "vlan-1"
        to           = "vlan-999"
        alloc_mode   = "static"
        role         = "external"
      }

      resource "aci_vlan_pool" "vmm_dynamic" {
        name       = join("", [var.pod_id, "_vmm_dynamic"])
        alloc_mode = "dynamic"
      }

      resource "aci_ranges" "vmware_dynamic_range1" {
        vlan_pool_dn = aci_vlan_pool.vmware_static.id
        from         = "vlan-1000"
        to           = "vlan-1999"
        alloc_mode   = "dynamic"
        role         = "external"
      }


    ### Attachable Entity Profile

      resource "aci_attachable_access_entity_profile" "cimc" {
        name = join("", [var.pod_id, "_vmware_cimc"])
        relation_infra_rs_dom_p = [
          aci_physical_domain.vmware.id
        ]
      }

      resource "aci_access_generic" "cimc" {
        name = "default"

        attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.cimc.id
      }

      resource "aci_attachable_access_entity_profile" "mgmt_esx" {
        name = join("", [var.pod_id, "_vmware_mgmt_esx"])
        relation_infra_rs_dom_p = [
          aci_physical_domain.vmware.id
        ]
      }

      resource "aci_access_generic" "mgmt_esx" {
        name = "default"

        attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.mgmt_esx.id
      }

      resource "aci_attachable_access_entity_profile" "client_esx" {
        name = join("", [var.pod_id, "_vmware_client_esx"])
        relation_infra_rs_dom_p = [
          aci_physical_domain.vmware.id
        ]
      }

      resource "aci_access_generic" "client_esx" {
        name = "default"

        attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.client_esx.id
      }



#### UKCLOUD MGMT Tenant ####
  # All configuration to be created under the ukcloud_mgmt tenant

  ### Data Sources ###

    data "aci_tenant" "ukcloud_mgmt" {
      name = var.ukcloud_mgmt_tenant
    }

    data "aci_l3_outside" "ukcloud_mgmt" {
      tenant_dn = data.aci_tenant.ukcloud_mgmt.id
      name      = var.ukcloud_mgmt_l3_out
    }

    data "aci_vrf" "ukcloud_mgmt" {
      tenant_dn = data.aci_tenant.ukcloud_mgmt.id
      name      = var.ukcloud_mgmt_vrf
    }

  ### Resources ###

    ## Application Profiles

      # Creates "pod_xxxxx_vmware" Application profile in the ukcloud_mgmt tenant
      resource "aci_application_profile" "vmware" {
        tenant_dn = data.aci_tenant.ukcloud_mgmt.id
        name      = join("", [var.pod_id, "_vmware"])
      }

    ## EPGs
      # For each EPG the 'relation_fv_rs_graph_def' attribute should be ignored as Terraform 
      # will write a null value to it, which will then be immediately overwritten by the APIC to a 
      # different value, resulting in a change showing each time a run is planned.

      # Creates the "podxxxxx_cimc" EPG
      resource "aci_application_epg" "cimc" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_cimc"])
        relation_fv_rs_bd      = aci_bridge_domain.cimc.id
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

      # Links the "podxxxxx_cimc" EPG to a physical domain
      resource "aci_epg_to_domain" "cimc_mgmt" {
        application_epg_dn = aci_application_epg.cimc_mgmt.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_cimc" EPG and VLAN tag to the CIMC AEP
      resource "aci_epgs_using_function" "cimc" {
        access_generic_dn = aci_access_generic.cimc.id
        tdn               = aci_application_epg.cimc.id
        encap             = "vlan-100"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_storage_mgmt" EPG
      resource "aci_application_epg" "storage_mgmt" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_storage_mgmt"])
        relation_fv_rs_bd      = aci_bridge_domain.storage_mgmt.id
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

      # Links the "podxxxxx_storage_mgmt" EPG to a physical domain
      resource "aci_epg_to_domain" "storage_mgmt" {
        application_epg_dn = aci_application_epg.storage_mgmt.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_storage_mgmt" EPG and VLAN tag to the CIMC AEP
      resource "aci_epgs_using_function" "storage_mgmt" {
        access_generic_dn = aci_access_generic.cimc.id
        tdn               = aci_application_epg.storage_mgmt.id
        encap             = "vlan-118"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_mgmt_cluster_vmware" EPG
      resource "aci_application_epg" "mgmt_cluster_vmware" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_mgmt"])
        relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_vmware.id
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

      # Links the "podxxxxx_mgmt_cluster_vmware" EPG to a physical domain
      resource "aci_epg_to_domain" "mgmt_cluster_vmware" {
        application_epg_dn = aci_application_epg.mgmt_cluster_vmware.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_mgmt_cluster_vmware" EPG and VLAN tag to the MGMT ESX AEP
      resource "aci_epgs_using_function" "mgmt_cluster_vmware" {
        access_generic_dn = aci_access_generic.mgmt_esx.id
        tdn               = aci_application_epg.mgmt_cluster_vmware.id
        encap             = "vlan-101"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_mgmt_cluster_tools" EPG
      resource "aci_application_epg" "mgmt_cluster_tools" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "mgmt_cluster_tools"])
        relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_tools.id
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

      # Links the "podxxxxx_mgmt_cluster_tools" EPG to a physical domain
      resource "aci_epg_to_domain" "mgmt_cluster_tools" {
        application_epg_dn = aci_application_epg.mgmt_cluster_tools.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_mgmt_cluster_tools" EPG and VLAN tag to the MGMT ESX AEP
      resource "aci_epgs_using_function" "mgmt_cluster_tools" {
        access_generic_dn = aci_access_generic.mgmt_esx.id
        tdn               = aci_application_epg.mgmt_cluster_tools.id
        encap             = "vlan-102"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_mgmt_cluster_vmotion" EPG
      resource "aci_application_epg" "mgmt_cluster_vmotion" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_mgmt_cluster_vmotion"])
        relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_vmotion.id
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

      # Links the "podxxxxx_mgmt_cluster_vmotion" EPG to a physical domain
      resource "aci_epg_to_domain" "mgmt_cluster_vmotion" {
        application_epg_dn = aci_application_epg.mgmt_cluster_vmotion.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_mgmt_cluster_vmotion" EPG and VLAN tag to the MGMT ESX AEP
      resource "aci_epgs_using_function" "mgmt_cluster_vmotion" {
        access_generic_dn = aci_access_generic.mgmt_esx.id
        tdn               = aci_application_epg.mgmt_cluster_vmotion.id
        encap             = "vlan-104"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_client_cluster_1_vmware" EPG
      resource "aci_application_epg" "client_cluster_1_vmware" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_client_cluster_1_vmware"])
        relation_fv_rs_bd      = aci_bridge_domain.client_cluster_1_vmware.id
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

      # Links the "podxxxxx_client_cluster_1_vmware" EPG to a physical domain
      resource "aci_epg_to_domain" "client_cluster_1_vmware" {
        application_epg_dn = aci_application_epg.client_cluster_1_vmware.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_client_cluster_1_vmware" EPG and VLAN tag to the Client ESX AEP
      resource "aci_epgs_using_function" "client_cluster_1_vmware" {
        access_generic_dn = aci_access_generic.client_esx.id
        tdn               = aci_application_epg.client_cluster_1_vmware.id
        encap             = "vlan-110"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_client_cluster_1_vmotion" EPG
      resource "aci_application_epg" "client_cluster_1_vmotion" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_client_cluster_1_vmotion"])
        relation_fv_rs_bd      = aci_bridge_domain.client_cluster_1_vmotion.id
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

      # Links the "podxxxxx_client_cluster_1_vmotion" EPG to a physical domain
      resource "aci_epg_to_domain" "client_cluster_1_vmotion" {
        application_epg_dn = aci_application_epg.client_cluster_1_vmotion.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_client_cluster_1_vmotion" EPG and VLAN tag to the Client ESX AEP
      resource "aci_epgs_using_function" "client_cluster_1_vmotion" {
        access_generic_dn = aci_access_generic.client_esx.id
        tdn               = aci_application_epg.client_cluster_1_vmotion.id
        encap             = "vlan-111"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_client_cluster_1_vxlan" EPG
      resource "aci_application_epg" "client_cluster_1_vxlan" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_client_cluster_1_vxlan"])
        relation_fv_rs_bd      = aci_bridge_domain.client_cluster_1_vxlan.id
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

      # Links the "podxxxxx_client_cluster_1_vxlan" EPG to a physical domain
      resource "aci_epg_to_domain" "client_cluster_1_vxlan" {
        application_epg_dn = aci_application_epg.client_cluster_1_vxlan.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_client_cluster_1_vxlan" EPG and VLAN tag to the Client ESX AEP
      resource "aci_epgs_using_function" "client_cluster_1_vxlan" {
        access_generic_dn = aci_access_generic.client_esx.id
        tdn               = aci_application_epg.client_cluster_1_vxlan.id
        encap             = "vlan-115"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

      # Creates the "podxxxxx_mgmt_cluster_avamar" EPG
      resource "aci_application_epg" "mgmt_cluster_avamar" {
        application_profile_dn = aci_application_profile.vmware.id
        name                   = join("", [var.pod_id, "_mgmt_cluster_avamar"])
        relation_fv_rs_bd      = aci_bridge_domain.mgmt_cluster_avamar.id
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

      # Links the "podxxxxx_mgmt_cluster_avamar" EPG to a physical domain
      resource "aci_epg_to_domain" "mgmt_cluster_avamar" {
        application_epg_dn = aci_application_epg.mgmt_cluster_avamar.id
        tdn                = aci_physical_domain.vmware.id
      }

      # Links the "podxxxxx_mgmt_cluster_avamar" EPG and VLAN tag to the Client ESX AEP
      resource "aci_epgs_using_function" "mgmt_cluster_avamar" {
        access_generic_dn = aci_access_generic.client_esx.id
        tdn               = aci_application_epg.mgmt_cluster_avamar.id
        encap             = "vlan-156"
        instr_imedcy      = "immediate"
        mode              = "regular"
      }

    ## Bridge Domains

      # Creates the "podxxxxx_cimc" bridge domain
      resource "aci_bridge_domain" "cimc" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_cimc"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_cimc" bridge domain
      resource "aci_subnet" "cimc" {
        parent_dn = aci_bridge_domain.cimc.id
        ip        = var.cimc_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_storage_mgmt" bridge domain
      resource "aci_bridge_domain" "storage_mgmt" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_storage_mgmt"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_storage_mgmt" bridge domain
      resource "aci_subnet" "storage_mgmt" {
        parent_dn = aci_bridge_domain.storage_mgmt.id
        ip        = var.storage_mgmt_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_mgmt_cluster_vmware" bridge domain
      resource "aci_bridge_domain" "mgmt_cluster_vmware" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_mgmt_cluster_vmware"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_mgmt_cluster_vmware" bridge domain
      resource "aci_subnet" "mgmt" {
        parent_dn = aci_bridge_domain.mgmt_cluster_vmware.id
        ip        = var.mgmt_cluster_vmware_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_mgmt_cluster_tools" bridge domain
      resource "aci_bridge_domain" "mgmt_cluster_tools" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_mgmt_cluster_tools"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_mgmt_cluster_tools" bridge domain
      resource "aci_subnet" "mgmt_cluster_tools" {
        parent_dn = aci_bridge_domain.mgmt_cluster_tools.id
        ip        = var.mgmt_cluster_tools_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_mgmt_cluster_vmotion" bridge domain
      resource "aci_bridge_domain" "mgmt_cluster_vmotion" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_mgmt_cluster_vmotion"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_mgmt_cluster_vmotion" bridge domain
      resource "aci_subnet" "mgmt_cluster_vmotion" {
        parent_dn = aci_bridge_domain.mgmt_cluster_vmotion.id
        ip        = var.mgmt_cluster_vmotion_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_mgmt_cluster_avamar" bridge domain
      resource "aci_bridge_domain" "mgmt_cluster_avamar" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_mgmt_cluster_avamar"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_mgmt_cluster_avamar" bridge domain
      resource "aci_subnet" "mgmt_cluster_avamar" {
        parent_dn = aci_bridge_domain.mgmt_cluster_avamar.id
        ip        = var.mgmt_cluster_avamar_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_client_cluster_1_vmware" bridge domain
      resource "aci_bridge_domain" "client_cluster_1_vmware" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_client_cluster_1_vmware"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_client_cluster_1_vmware" bridge domain
      resource "aci_subnet" "client_cluster_1_vmware" {
        parent_dn = aci_bridge_domain.client_cluster_1_vmware.id
        ip        = var.client_cluster_1_vmware_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_client_cluster_1_vmotion" bridge domain
      resource "aci_bridge_domain" "client_cluster_1_vmotion" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_client_cluster_1_vmotion"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_client_cluster_1_vmotion" bridge domain
      resource "aci_subnet" "client_cluster_1_vmotion" {
        parent_dn = aci_bridge_domain.client_cluster_1_vmotion.id
        ip        = var.client_cluster_1_vmotion_bd_subnet
        scope = [
          "public"
        ]
      }

      # Creates the "podxxxxx_client_cluster_1_vxlan" bridge domain
      resource "aci_bridge_domain" "client_cluster_1_vxlan" {
        tenant_dn           = data.aci_tenant.ukcloud_mgmt.id
        name                = join("", [var.pod_id, "_client_cluster_1_vxlan"])
        ep_move_detect_mode = "garp"
        relation_fv_rs_bd_to_out = [
          data.aci_l3_outside.skyscape_mgmt.id
        ]
        relation_fv_rs_ctx = data.aci_vrf.skyscape_mgmt.id
      }

      # Creates a subnet for the "podxxxxx_client_cluster_1_vxlan" bridge domain
      resource "aci_subnet" "client_cluster_1_vxlan" {
        parent_dn = aci_bridge_domain.client_cluster_1_vxlan.id
        ip        = var.client_cluster_1_vxlan_bd_subnet
        scope = [
          "public"
        ]
      }

















#############
#############
#Switch Profiles

resource "aci_leaf_profile" "openstack" {
  name = join("", ["openstack_", var.pod_id, "_profile"])

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

resource "aci_leaf_selector" "openstack" {
  leaf_profile_dn         = aci_leaf_profile.openstack.id
  name                    = join("", ["openstack_", var.pod_id, "_switch_selector"])
  switch_association_type = "range"
}

resource "aci_node_block" "openstack" {
  for_each = toset(var.pod_nodes)

  switch_association_dn = aci_leaf_selector.openstack.id
  name                  = join("", [var.pod_id, "_", each.key])
  from_                 = each.key
  to_                   = each.key
}

### Interface Profiles

# Port 1

resource "aci_leaf_interface_profile" "port_1" {
  name = join("", [var.pod_id, "_openstack_port_1"])
}

resource "aci_access_port_selector" "port_1" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_1.id
  name                           = "Port-1"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_2"])
}

resource "aci_access_port_selector" "port_2" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_2.id
  name                           = "Port-2"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_3"])
}

resource "aci_access_port_selector" "port_3" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_3.id
  name                           = "Port-3"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_4"])
}

resource "aci_access_port_selector" "port_4" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_4.id
  name                           = "Port-4"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_5"])
}

resource "aci_access_port_selector" "port_5" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_5.id
  name                           = "Port-5"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_6"])
}

resource "aci_access_port_selector" "port_6" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_6.id
  name                           = "Port-6"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_7"])
}

resource "aci_access_port_selector" "port_7" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_7.id
  name                           = "Port-7"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_8"])
}

resource "aci_access_port_selector" "port_8" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_8.id
  name                           = "Port-8"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_9"])
}

resource "aci_access_port_selector" "port_9" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_9.id
  name                           = "Port-9"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_10"])
}

resource "aci_access_port_selector" "port_10" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_10.id
  name                           = "Port-10"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_11"])
}

resource "aci_access_port_selector" "port_11" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_11.id
  name                           = "Port-11"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_12"])
}

resource "aci_access_port_selector" "port_12" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_12.id
  name                           = "Port-12"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_13"])
}

resource "aci_access_port_selector" "port_13" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_13.id
  name                           = "Port-13"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_14"])
}

resource "aci_access_port_selector" "port_14" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_14.id
  name                           = "Port-14"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_15"])
}

resource "aci_access_port_selector" "port_15" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_15.id
  name                           = "Port-15"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_16"])
}

resource "aci_access_port_selector" "port_16" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_16.id
  name                           = "Port-16"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_17"])
}

resource "aci_access_port_selector" "port_17" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_17.id
  name                           = "Port-17"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_18"])
}

resource "aci_access_port_selector" "port_18" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_18.id
  name                           = "Port-18"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_19"])
}

resource "aci_access_port_selector" "port_19" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_19.id
  name                           = "Port-19"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_20"])
}

resource "aci_access_port_selector" "port_20" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_20.id
  name                           = "Port-20"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_21"])
}

resource "aci_access_port_selector" "port_21" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_21.id
  name                           = "Port-21"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_22"])
}

resource "aci_access_port_selector" "port_22" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_22.id
  name                           = "Port-22"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_23"])
}

resource "aci_access_port_selector" "port_23" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_23.id
  name                           = "Port-23"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_24"])
}

resource "aci_access_port_selector" "port_24" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_24.id
  name                           = "Port-24"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", [var.pod_id, "_openstack_port_25"])
}

resource "aci_access_port_selector" "port_25" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.port_25.id
  name                           = "Port-25"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.openstack.id
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
  name = join("", ["pol_grp_40G_cdp_lldp_openstack_hosts_", var.pod_id])
    relation_infra_rs_h_if_pol    = "uni/infra/hintfpol-40G"
    relation_infra_rs_cdp_if_pol  = "uni/infra/cdpIfP-cdp_enabled"
    relation_infra_rs_lldp_if_pol = "uni/infra/lldpIfP-lldp_enabled"
    
  relation_infra_rs_att_ent_p = aci_attachable_access_entity_profile.openstack.id
}