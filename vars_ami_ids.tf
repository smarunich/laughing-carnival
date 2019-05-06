# This file contains the AMI Ids of the images used for the various instances
#

# aws ec2 describe-images --owners 139284885014 --filters Name=name,Values='Avi-Controller-17.2.8*' --region eu-west-2 | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId'
variable "ami_avi_controller" {
  type        = "map"
  description = "Avi AMI by region updated 07/01/19"

  default = {
    eu-west-1 = "ami-072e0c55a6dc19cd1" #18.2.2
    us-west-2 = "ami-0cc9be68abe0b4578" #18.2.3
    #us-west-2 = "ami-0ef13f76789a1223b" #18.2.2
  }
}

# aws ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce --region eu-west-2 | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId'

# NOTE
# Prebuilt packer image is used in labs
variable "ami_centos" {
  type        = "map"
  description = "CentOS AMI by region updated 10/10/18"

  default = {
    eu-west-1 = "ami-0defbd4ca292ce6e5"
    us-west-2 = "ami-01161bd085729d109"
  }
}
