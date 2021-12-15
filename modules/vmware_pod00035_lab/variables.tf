variable "pod_id" {
  type        = string
  description = "The pod CI number; e.g. pod0001c"
}

variable "interface_map" {
  type = map(object({
    node_ids   = list(string)
    clnt_ports = list(string)
    mgmt_ports = list(string)
    cimc_ports = list(string)
  }))
}

variable "link_level_policy" {
  type        = string
  default     = "uni/infra/hintfpol-40G"
  description = <<EOT
  The DN of the Link Level Policy, e.g;
  uni/infra/hintfpol-40G

  You can also use the output value from the output value from the fabric_base module;
  module.fabric_base.aci_fabric_if_pol_40G

  If this variable is not specified it will use the default value;
  uni/infra/hintfpol-40G
  EOT
}

variable "cdp_enabled_policy" {
  type        = string
  default     = "uni/infra/cdpIfP-cdp_enabled"
  description = <<EOT
  The DN of the CDP Enabled Polic, e.g;
  uni/infra/cdpIfP-cdp_enabled

  You can also use the output value from the output value from the fabric_base module;
  module.fabric_base.aci_cdp_interface_policy_enabled

  If this variable is not specified it will use the default value;
  uni/infra/cdpIfP-cdp_enabled
  EOT
}

variable "cdp_disabled_policy" {
  type        = string
  default     = "uni/infra/cdpIfP-cdp_disabled"
  description = <<EOT
  The DN of the CDP Disabled Policy, e.g;
  uni/infra/cdpIfP-cdp_disabled

  You can also use the output value from the output value from the fabric_base module;
  module.fabric_base.aci_cdp_interface_policy_disabled

  If this variable is not specified it will use the default value;
  uni/infra/cdpIfP-cdp_disabled
  EOT
}

variable "lldp_enabled_policy" {
  type        = string
  default     = "uni/infra/lldpIfP-lldp_enabled"
  description = <<EOT
  The DN of the LLDP Enabled Policy, e.g;
  uni/infra/lldpIfP-lldp_enabled

  You can also use the output value from the output value from the fabric_base module;
  module.fabric_base.aci_lldp_interface_policy_enabled

  If this variable is not specified it will use the default value;
  uni/infra/lldpIfP-lldp_enabled
  EOT
}

variable "lldp_disabled_policy" {
  type        = string
  default     = "uni/infra/lldpIfP-lldp_disabled"
  description = <<EOT
  The DN of the LLDP Disabled Policy, e.g;
  uni/infra/lldpIfP-lldp_disabled

  You can also use the output value from the output value from the fabric_base module;
  module.fabric_base.aci_lldp_interface_policy_disabled

  If this variable is not specified it will use the default value;
  uni/infra/lldpIfP-lldp_disabled
  EOT
}

variable "ukcloud_mgmt_tenant" {
  type        = string
  description = <<EOT
  The DN of the assured_ukcloud_mgmt or elevated_ukcloud_mgmt tenant, e.g;
  uni/tn-assured_ukcloud_mgmt

  You can also use the output value from the output value from the assured_ukcloud_mgmt or elevated_ukcloud_mgmt module;
  module.assured_ukcloud_mgmt.tenant
  module.elevated_ukcloud_mgmt.tenant
  EOT
}

variable "ukcloud_mgmt_l3_out" {
  type        = string
  description = <<EOT
  The DN of the assured_ukcloud_mgmt or elevated_ukcloud_mgmt l3_out, e.g;
  uni/tn-assured_ukcloud_mgmt/out-assured_ukcloud_mgmt

  You can also use the output value from the output value from the assured_ukcloud_mgmt or elevated_ukcloud_mgmt module;
  module.assured_ukcloud_mgmt.l3out
  module.elevated_ukcloud_mgmt.l3out
  EOT
}

variable "ukcloud_mgmt_vrf" {
  type        = string
  description = <<EOT
  The DN of the assured_ukcloud_mgmt or elevated_ukcloud_mgmt vrf, e.g;
  uni/tn-assured_ukcloud_mgmt/ctx-assured_ukcloud_mgmt

  You can also use the output value from the output value from the assured_ukcloud_mgmt or elevated_ukcloud_mgmt module;
  module.assured_ukcloud_mgmt.vrf
  module.elevated_ukcloud_mgmt.vrf
  EOT
}

variable "protection_tenant" {
  type        = string
  description = <<EOT
  The DN of the assured_protection or elevated_protection tenant, e.g;
  uni/tn-assured_protection

  You can also use the output value from the output value from the assured_protection or elevated_ukcloud_mgmt module;
  module.assured_protection.tenant
  module.elevated_protection.tenant
  EOT
}

variable "protection_l3_out" {
  type        = string
  description = <<EOT
  The DN of the assured_protection or elevated_protection l3_out, e.g;
  uni/tn-assured_protection/out-assured_protection

  You can also use the output value from the output value from the assured_protection or elevated_protection module;
  module.assured_protection.l3out
  module.elevated_protection.l3out
  EOT
}

variable "protection_vrf" {
  type        = string
  description = <<EOT
  The DN of the assured_protection or elevated_protectionvrf, e.g;
  uni/tn-assured_protection/ctx-assured_protection

  You can also use the output value from the output value from the assured_protection or elevated_protection module;
  module.assured_protection.vrf
  module.elevated_protection.vrf
  EOT
}

variable "cimc_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_cimc bridge domain"
}

variable "mgmt_cluster_vmware_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_vmware bridge domain"
}

variable "mgmt_cluster_vsan_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_vsan bridge domain"
}

variable "mgmt_cluster_vmotion_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_vmotion bridge domain"
}

variable "mgmt_cluster_transit_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_transit bridge domain"
}

variable "mgmt_cluster_host_overlay_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_host_overlay bridge domain"
}

variable "mgmt_cluster_edge_overlay_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_cluster_edge_overlay bridge domain"
}

variable "mgmt_vmm_subnets" {
  type        = list(string)
  description = "List of subnets in the podxxxxx_mgmt_vmm bridge domain"
}

variable "vmm_ci" {
  type        = string
  description = "The CI for the VMM controller; e.g vcv00004i2"
}

variable "vmm_host" {
  type        = string
  description = "The IP address or hostname for the VMM controller; e.g 10.40.16.151"
}

variable "vmm_svc_acc" {
  type        = string
  description = "The service account username and domain for VMM integration; e.g svc_pod00008-vmm@il2management"
}
