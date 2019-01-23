# Terraform definition for the lab masters
#

data "template_file" "master_userdata" {
  count = "${var.master_count * var.student_count}"
  template = "${file("${path.module}/userdata/master.userdata")}"

  vars {
    hostname = "master${(count.index / var.student_count % var.master_count) + 1}.student${count.index % var.student_count + 1}.lab"
    jump_ip  = "${aws_instance.jump.private_ip}"
    number   = "${count.index + 1}"
  }
}
resource "aws_instance" "master" {
  count                  = "${var.master_count * var.student_count}"
  ami                    = "${lookup(var.ami_centos, var.aws_region)}"
  availability_zone      = "${lookup(var.aws_az, var.aws_region)}"
  instance_type          = "${var.flavour_centos}"
  key_name               = "${var.key}"
  vpc_security_group_ids = ["${aws_security_group.jumpsg.id}"]
  subnet_id              = "${aws_subnet.pubnet.id}"
  associate_public_ip_address = true
  #private_ip             = "${format("%s%02d", cidrhost(aws_subnet.privnet.cidr_block,1) , count.index + 1)}"
  source_dest_check      = false
  user_data              = "${data.template_file.master_userdata.*.rendered[count.index]}"
  depends_on             = ["aws_instance.jump"]

  tags {
    Name  = "master${count.index + 1}"
    Owner = "${var.owner}"
    Lab_Group = "servers"
    Lab_Name = "master${(count.index / var.student_count % var.master_count) + 1}.student${count.index % var.student_count + 1}.lab"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = "${var.vol_size_centos}"
    delete_on_termination = "true"
  }
}
