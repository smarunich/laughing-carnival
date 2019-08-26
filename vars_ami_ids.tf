# This file contains the AMI Ids of the images used for the various instances
#

# aws ec2 describe-images --owners 139284885014 --filters Name=name,Values='Avi-Controller-17.2.8*' --region eu-west-2 | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId'
variable "ami_avi_controller" {
  type        = map(string)
  description = "Avi AMI by region updated 07/01/19"

  default = {
    eu-west-1 = "ami-0e81793951f5d3e2d" #18.2.5
    us-east-1 = "ami-07f26188aeeedd5dc" #18.2.5
    us-west-2 = "ami-0ae2dd07fcfd8c1d0" #18.2.5
  }
}

# aws ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce --region eu-west-2 | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId'

# NOTE
# Prebuilt packer image is used in labs
variable "ami_centos" {
  type        = map(string)
  description = "CentOS AMI by region updated 10/10/18"

  default = {
    eu-west-1 = "ami-0defbd4ca292ce6e5"
    us-west-2 = "ami-01161bd085729d109"
  }
}
