# packerでspot instanceを構築してみる
# ビルドは簡単だが、起動したあと、コンソールに行って、リクエストキャンセルしないといけなかった
# 停止することも考えるとそれはterraformでやったほうが良さそう
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "learn-packer-linux-aws-redis"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
    ami_name      = "${var.ami_prefix}-${local.timestamp}"
    region        = "us-west-2"
    spot_instance_types = ["t3.micro"]
    spot_price = "0.004" # 時間あたりの単価
    source_ami_filter {
        filters = {
            name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
            root-device-type    = "ebs"
            virtualization-type = "hvm"
        }
        most_recent = true
        owners      = ["099720109477"]
    }
    ssh_username = "ubuntu"
}

build {
    sources = [
        "source.amazon-ebs.ubuntu",
    ]

}
