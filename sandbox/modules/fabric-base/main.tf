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