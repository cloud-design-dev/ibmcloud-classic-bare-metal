locals {
  prefix          = var.project_prefix != "" ? var.project_prefix : "${random_string.prefix.0.result}-lab"
  public_vlan_id  = var.public_vlan_name != "" ? data.ibm_network_vlan.public[0].id : ibm_network_vlan.public[0].id
  private_vlan_id = var.private_vlan_name != "" ? data.ibm_network_vlan.private[0].id : ibm_network_vlan.private[0].id
  ssh_key_ids     = var.existing_ssh_key != "" ? [data.ibm_compute_ssh_key.existing[0].id] : [ibm_compute_ssh_key.generated_key[0].id]
  tags = [
    "project:${local.prefix}",
    "datacenter:${var.datacenter}",
    "owner:${var.owner}",
    "provider:ibm"
  ]
}

resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  upper   = false
}


resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "create_private_key" {
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.ssh.private_key_pem}' > ./'${local.prefix}'.pem
      chmod 400 ./'${local.prefix}'.pem
    EOT
  }
}

resource "ibm_compute_ssh_key" "generated_key" {
  count      = var.existing_ssh_key != "" ? 0 : 1
  label      = "${local.prefix}-sshkey"
  public_key = tls_private_key.ssh.public_key_openssh
  tags       = local.tags
}

resource "ibm_network_vlan" "public" {
  count      = var.public_vlan_name != "" ? 0 : 1
  name       = "${local.prefix}-public"
  datacenter = var.datacenter
  type       = "PUBLIC"
  tags       = local.tags
}

resource "ibm_network_vlan" "private" {
  count           = var.private_vlan_name != "" ? 0 : 1
  name            = "${local.prefix}-private"
  datacenter      = var.datacenter
  type            = "PRIVATE"
  router_hostname = replace(ibm_network_vlan.public[0].router_hostname, "/^f/", "b")
  tags            = local.tags
}

resource "ibm_compute_bare_metal" "monthly_bm1" {
  package_key_name     = "DUAL_INTEL_XEON_PROC_CASCADE_LAKE_SCALABLE_FAMILY_12_DRIVES"
  process_key_name     = "INTEL_INTEL_XEON_8260_2_40"
  memory               = 384
  os_key_name          = "OS_UBUNTU_20_04_LTS_FOCAL_FOSSA_64_BIT"
  hostname             = local.prefix
  domain               = (var.domain != "" ? var.domain : "rst.com")
  datacenter           = var.datacenter
  network_speed        = 10000
  public_bandwidth     = 500
  disk_key_names       = ["HARD_DRIVE_960GB_SSD", "HARD_DRIVE_960GB_SSD", "HARD_DRIVE_1_00_TB_SATA_2", "HARD_DRIVE_1_00_TB_SATA_2"]
  hourly_billing       = false
  ssh_key_ids          = local.ssh_key_ids
  private_network_only = false
  unbonded_network     = true
  public_vlan_id       = local.public_vlan_id
  private_vlan_id      = local.private_vlan_id

  tags                   = local.tags
  redundant_power_supply = true
  storage_groups {
    # RAID 1
    array_type_id = 2
    # Use the first two disks
    hard_drives = [0, 1]
    array_size  = 960

  }
}