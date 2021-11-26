variable "a_username" {
  type        = string
  sensitive   = true
  description = "Username for accessing the APIC"
}

variable "b_password" {
  type        = string
  sensitive   = true
  description = "Password for accessing the APIC"
}