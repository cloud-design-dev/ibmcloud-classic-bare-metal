data "ibm_compute_ssh_key" "existing" {
  count = var.existing_ssh_key != "" ? 1 : 0
  label = var.existing_ssh_key
}

data "ibm_network_vlan" "public" {
  count  = var.public_vlan_name != "" ? 1 : 0
  name   = (var.public_vlan_name != "" ? var.public_vlan_name : null)
  number = (var.public_vlan_number != "" ? var.public_vlan_number : null)
}

data "ibm_network_vlan" "private" {
  count  = var.private_vlan_name != "" ? 1 : 0
  name   = (var.private_vlan_name != "" ? var.private_vlan_name : null)
  number = (var.private_vlan_number != "" ? var.private_vlan_number : null)
}

# pragma: allowlist secret
data "ibm_secrets_manager_secret" "logdna_key" {
  instance_id = var.sm_instance_id
  secret_type = "arbitrary"
  secret_id   = var.sm_logging_secret_id
}

data "ibm_secrets_manager_secret" "sysdig_key" {
  instance_id = var.sm_instance_id
  secret_type = "arbitrary"
  secret_id   = var.sm_monitoring_secret_id
}
