variable "project_prefix" {
  description = "Prefix to add to all deployed resources. If none is provided, a random string will be generated."
  type        = string
  default     = ""
}

variable "datacenter" {
  description = "Datacenter where bare metal and VLANs will be created."
  type        = string
}

variable "domain" {
  description = "Domain to use for bare metal host."
  type        = string
  default     = ""
}

variable "owner" {
  description = "Owner of the project. Will be added as a tag to the VLANs and Bare metal host."
  type        = string
}

variable "public_vlan_name" {
  description = "Name of an existing public VLAN in the targetted datacenter. If the VLAN does not have a name you will need to supply the variable `public_vlan_number`."
  type        = string
  default     = ""
}

variable "private_vlan_name" {
  description = "Name of an existing Private VLAN in the targetted datacenter. If the VLAN does not have a name you will need to supply the variable `private_vlan_number`."
  type        = string
  default     = ""
}

variable "public_vlan_number" {
  description = "Number of an existing public VLAN in the targetted datacenter. This is needed if the VLAN does not have a name."
  type        = string
  default     = ""
}

variable "private_vlan_number" {
  description = "Number of an existing private VLAN in the targetted datacenter. This is needed if the VLAN does not have a name."
  type        = string
  default     = ""
}

variable "existing_ssh_key" {}
