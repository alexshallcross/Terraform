### CDP Interface Policies

    resource "aci_cdp_interface_policy" "disabled" {
        name      = "cdp_disabled"
        admin_st  = "disabled"
    }

    resource "aci_cdp_interface_policy" "enabled" {
        name      = "cdp_enabled"
        admin_st  = "enabled"
    }

### LLDP Interface Policies

    resource "aci_lldp_interface_policy" "disabled" {
        name        = "lldp_disabled"
        admin_rx_st = "disabled"
        admin_tx_st = "disabled"
    }

    resource "aci_lldp_interface_policy" "enabled" {
        name        = "lldp_enabled"
        admin_rx_st = "enabled"
        admin_tx_st = "enabled"
    }

### LACP Policies

    resource "aci_lacp_policy" "enabled" {
        name        = "lacp_active"
        ctrl        = ["fast-sel-hot-stdby", "susp-individual", "graceful-conv"]
        max_links   = "16"
        min_links   = "1"
        mode        = "active"
    }

### Interface Link Level Policies

    resource "aci_fabric_if_pol" "_1G" {
        name          = "1G"
        auto_neg      = "on"
        link_debounce = "100"
        speed         = "1G"
    }

    resource "aci_fabric_if_pol" "_1G_no_auto_neg" {
        name          = "1G"
        auto_neg      = "off"
        link_debounce = "100"
        speed         = "1G"
    }

    resource "aci_fabric_if_pol" "_10G" {
        name          = "10G"
        auto_neg      = "on"
        link_debounce = "100"
        speed         = "10G"
    }

    resource "aci_fabric_if_pol" "_10G_no_auto_neg" {
        name          = "10G"
        auto_neg      = "off"
        link_debounce = "100"
        speed         = "10G"
    }

    resource "aci_fabric_if_pol" "_40G" {
        name          = "40G"
        auto_neg      = "on"
        link_debounce = "100"
        speed         = "40G"
    }

    resource "aci_fabric_if_pol" "_40G_no_auto_neg" {
        name          = "40G"
        auto_neg      = "off"
        link_debounce = "100"
        speed         = "40G"
    }

### In-Band Management

    resource "aci_vlan_pool" "inband_mgmt" {
        name       = "vlan_static_inband_mgmt"
        alloc_mode = "static"
    }

        resource "aci_ranges" "inband_mgmt" {
            vlan_pool_dn = aci_vlan_pool.inband_mgmt.id
            _from        = "vlan-10"
            to           = "vlan-10"
            alloc_mode   = "static"
        }

    resource "aci_physical_domain" "inband_mgmt" {
        name = "inband_mgmt"

        relation_infra_rs_vlan_ns = aci_vlan_pool.inband_mgmt.id
    }

    resource "aci_attachable_access_entity_profile" "inband_mgmt" {
        name = "inband_mgmt"

        relation_infra_rs_dom_p = [
            aci_physical_domain.inband_mgmt.id
        ]
    }

    resource "aci_leaf_access_port_policy_group" "inband_mgmt" {
        name = "apic_controllers"

        relation_infra_rs_h_if_pol    = aci_fabric_if_pol._40G.id
        relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.enabled.id
        relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.enabled.id
        relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.inband_mgmt.id
    }

    resource "aci_leaf_interface_profile" "inband_mgmt" {
        name = "apic_controllers"
    }

        resource "aci_access_port_selector" "port_46" {
            leaf_interface_profile_dn      = aci_leaf_interface_profile.inband_mgmt.id
            name                           = "Port-46"
            access_port_selector_type      = "range"
            relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.inband_mgmt.id
        }

            resource "aci_access_port_block" "port_46" {
                access_port_selector_dn = aci_access_port_selector.port_46.id
                from_card               = "1"
                from_port               = "46"
                to_card                 = "1"
                to_port                 = "46"
            }

        resource "aci_access_port_selector" "port_47" {
            leaf_interface_profile_dn      = aci_leaf_interface_profile.inband_mgmt.id
            name                           = "Port-47"
            access_port_selector_type      = "range"
            relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.inband_mgmt.id
        }

            resource "aci_access_port_block" "port_47" {
                access_port_selector_dn = aci_access_port_selector.port_47.id
                from_card               = "1"
                from_port               = "47"
                to_card                 = "1"
                to_port                 = "47"
            }

        resource "aci_access_port_selector" "port_48" {
            leaf_interface_profile_dn      = aci_leaf_interface_profile.inband_mgmt.id
            name                           = "Port-48"
            access_port_selector_type      = "range"
            relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.inband_mgmt.id
        }

            resource "aci_access_port_block" "port_48" {
                access_port_selector_dn = aci_access_port_selector.port_48.id
                from_card               = "1"
                from_port               = "48"
                to_card                 = "1"
                to_port                 = "48"
            }

    resource "aci_leaf_profile" "inband_mgmt" {
        name = "inband_mgmt_profile"

        relation_infra_rs_acc_port_p = [
            aci_leaf_interface_profile.inband_mgmt.id
        ]
    }

        resource "aci_leaf_selector" "inband_mgmt" {
            leaf_profile_dn         = aci_leaf_profile.inband_mgmt.id
            name                    = "inband_mgmt_switch_selector"
            switch_association_type = "range"
        }

            resource "aci_node_block" "inband_mgmt" {
                switch_association_dn = aci_leaf_selector.inband_mgmt.id
                name                  = "e96125f97531b1d1"
                from_                 = "901"
                to_                   = "902"
            }

    resource "aci_vlan_pool" "elevated_mgmt" {
        name = "vlan_static_l3_out_elevated_mgmt"
        alloc_mode = "static"
    }

        resource "aci_ranges" "elevated_mgmt" {
            vlan_pool_dn = aci_vlan_pool.elevated_mgmt.id
            _from        = "vlan-3900"
            to           = "vlan-3900"
            alloc_mode   = "static"
            role         = "external"
        }

    resource "aci_l3_domain_profile" "elevated_mgmt" {
        name = "l3_out_elevated_mgmt"
        relation_infra_rs_vlan_ns = aci_vlan_pool.elevated_mgmt.id
    }

    resource "aci_attachable_access_entity_profile" "elevated_mgmt" {
        name = "elevated_private_peering"
        relation_infra_rs_dom_p = aci_l3_domain_profile.elevated_mgmt.id
    }

    resource "aci_leaf_access_port_policy_group" "elevated_mgmt" {
        name = "elevated_private_peering"

        relation_infra_rs_cdp_if_pol  = aci_cdp_interface_policy.enabled.id
        relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.enabled.id
        relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.elevated_private_peering.id
    }

    resource "aci_leaf_interface_profile" "elevated_mgmt" {
        name = "elevated_private_peering"
    }

        resource "aci_access_port_selector" "port_33" {
            leaf_interface_profile_dn      = aci_leaf_interface_profile.elevated_mgmt.id
            name                           = "Port-33"
            access_port_selector_type      = "range"
            relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.elevated_mgmt.id
        }

            resource "aci_access_port_block" "port_33" {
                access_port_selector_dn = aci_access_port_selector.port_33.id
                from_card               = "1"
                from_port               = "46"
                to_card                 = "1"
                to_port                 = "46"
            }

        resource "aci_access_port_selector" "port_34" {
            leaf_interface_profile_dn      = aci_leaf_interface_profile.elevated_mgmt.id
            name                           = "Port-34"
            access_port_selector_type      = "range"
            relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.elevated_mgmt.id
        }

            resource "aci_access_port_block" "port_34" {
                access_port_selector_dn = aci_access_port_selector.port_34.id
                from_card               = "1"
                from_port               = "34"
                to_card                 = "1"
                to_port                 = "34"
            }

    resource "aci_leaf_profile" "elevated_mgmt" {
        name = "elevated_private_peering"

        relation_infra_rs_acc_port_p = [
            aci_leaf_interface_profile.elevated_mgmt.id
        ]
    }

        resource "aci_leaf_selector" "elevated_mgmt" {
            leaf_profile_dn         = aci_leaf_profile.elevated_mgmt.id
            name                    = "elevated_private_peering_switch_selector"
            switch_association_type = "range"
        }

            resource "aci_node_block" "elevated_mgmt" {
                switch_association_dn = aci_leaf_selector.elevated_mgmt.id
                name                  = "a1f2705d1ge02z7j"
                from_                 = "901"
                to_                   = "904"
            }

    resource "aci_ospf_interface_policy" "elevated_mgmt" {
        tenant_dn    = "uni/tn-mgmt"
        name         = "ospf_int_p2p_protocol_policy_elevated_mgmt"
    }

    resource "aci_l3_outside" "elevated_mgmt" {
        name = "l3_out_elevated_mgmt"
    }

        resource "aci_logical_node_profile" "elevated_mgmt" {
            l3_outside_dn = aci_l3_outside.elevated_mgmt.id
            name = "ospf_node_profile_mgmt"
        }

            resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_901" {
                logical_node_profile_dn  = aci_logical_node_profile.elevated_mgmt.id
                tDn  = "topology/pod-1/node-901"
                rtr_id  = "10.41.37.2"
                }
            
            resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_902" {
                logical_node_profile_dn  = aci_logical_node_profile.elevated_mgmt.id
                tDn  = "topology/pod-1/node-902"
                rtr_id  = "10.41.37.10"
                }

            resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_903" {
                logical_node_profile_dn  = aci_logical_node_profile.elevated_mgmt.id
                tDn  = "topology/pod-1/node-903"
                rtr_id  = "10.41.37.18"
                }

            resource "aci_logical_node_to_fabric_node" "elevated_mgmt_node_904" {
                logical_node_profile_dn  = aci_logical_node_profile.elevated_mgmt.id
                tDn  = "topology/pod-1/node-904"
                rtr_id  = "10.41.37.26"
                }

            resource "aci_logical_interface_profile" "elevated_mgmt" {
                logical_node_profile_dn = "${aci_logical_node_profile.example.id}"
                description             = aci_logical_node_profile.elevated_mgmt.id
                name                    = "ospf_int_profile_mgmt"
                tag                     = "yellow-green"
            }

        resource "aci_external_network_instance_profile" "elevated_mgmt" {
            l3_outside_dn  = aci_l3_outside.elevated_mgmt.id
            name           = "all"
        }

            resource "aci_l3_ext_subnet" "all" {
                external_network_instance_profile_dn  = aci_external_network_instance_profile.elevated_mgmt.id
                ip                                    = "0.0.0.0/0"
            }