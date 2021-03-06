# Terraform definition for the lab jumpbox
#

data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jumpbox.userdata")

  vars = {
    hostname     = "${var.id}_jump"
    server_count = var.student_count
    vpc_id       = aws_vpc.OCP_vpc.id
    region       = var.aws_region
    az           = var.aws_az[var.aws_region]
    mgmt_net     = aws_subnet.mgmtnet.tags.Name
    pkey         = var.pkey
  }
}

resource "aws_instance" "jump" {
  ami               = var.ami_centos[var.aws_region]
  availability_zone = var.aws_az[var.aws_region]
  instance_type     = var.flavour_centos
  key_name          = var.key
  vpc_security_group_ids      = [aws_security_group.jumpsg.id]
  subnet_id                   = aws_subnet.pubnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.lab_profile.name
  source_dest_check           = false
  user_data                   = data.template_file.jumpbox_userdata.rendered
  depends_on                  = [aws_internet_gateway.igw]

  tags = {
    Name                          = "${var.id}_jumpbox"
    Owner                         = var.owner
    Lab_Group                     = "jumpbox"
    Lab_Name                      = "jumpbox.student.lab"
    Lab_vpc_id                    = aws_vpc.OCP_vpc.id
    Lab_avi_default_password      = var.avi_default_password
    Lab_avi_admin_password        = var.avi_admin_password
    Lab_ocp_oreg_auth_user        = var.ocp_oreg_auth_user
    Lab_ocp_oreg_auth_password    = var.ocp_oreg_auth_password
    Lab_ocp_rhsm_pool_id          = var.ocp_rhsm_pool_id
    Lab_ocp_rhsm_org              = var.ocp_rhsm_org
    Lab_ocp_rhsm_activationkey    = var.ocp_rhsm_activationkey
    Lab_avi_backup_admin_username = var.avi_backup_admin_username
    Lab_avi_backup_admin_password = var.avi_backup_admin_password
    Lab_avi_management_network    = "${var.id}_management_network"
    Lab_avi_vip_network           = "${var.id}_infra_network"
    Lab_Timezone                  = var.lab_timezone
    Lab_Noshut                    = "jumpbox"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = var.vol_size_centos
    delete_on_termination = "true"
  }

  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    agent       = false
    private_key = file("${path.module}/keys/internal-root")
  }

  provisioner "file" {
    source      = "provisioning/bootstrap"
    destination = "/opt/bootstrap"
  }

  provisioner "file" {
    source      = "provisioning/handle_bootstrap.py"
    destination = "/usr/local/bin/handle_bootstrap.py"
  }

  provisioner "file" {
    source      = "provisioning/handle_bootstrap.service"
    destination = "/etc/systemd/system/handle_bootstrap.service"
  }

  provisioner "file" {
    source      = "provisioning/handle_register.py"
    destination = "/usr/local/bin/handle_register.py"
  }

  provisioner "file" {
    source      = "provisioning/handle_register.service"
    destination = "/etc/systemd/system/handle_register.service"
  }

  provisioner "file" {
    source      = "provisioning/create_backup_user.yml"
    destination = "/root/create_backup_user.yml"
  }

  provisioner "file" {
    source      = "provisioning/ansible_inventory.py"
    destination = "/etc/ansible/hosts"
  }

  provisioner "file" {
    source      = "provisioning/cleanup_controllers.py"
    destination = "/usr/local/bin/cleanup_controllers.py"
  }

  provisioner "remote-exec" {
    scripts = [
      "provisioning/provision_jumpbox.sh",
    ]
  }
}

