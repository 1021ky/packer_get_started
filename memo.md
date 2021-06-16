# Why Packer

> Increased Dev / Production Parity
> Keep dev, staging, and production environments as similar as
> possible by generating images for multiple platforms at the same time.

いくつかPackerを使う目的が書かれていたけど、これは一番うまみがあると感じた。

あとはTerraformとの親和性かな

> Rapid Infrastructure Deployment
> Use Terraform to launch completely provisioned and configured machine instances with Packer images in seconds.

Packerでイメージを作ってTerraformで迅速に配置。

# [Getting Started with Docker](https://learn.hashicorp.com/collections/packer/docker-get-started)

## [Install Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli?in=packer/docker-get-started)

```zsh
vaivailx@MacBook-Pro-2 get_started % brew tap hashicorp/tap
Updating Homebrew...
==> Auto-updated Homebrew!
Updated 4 taps (hashicorp/tap, homebrew/core, homebrew/cask and homebrew/services).
==> New Formulae
argocd-autopilot  code-minimap      mongosh           pywhat
at-spi2-atk       gpg-tui           osinfo-db         simde
at-spi2-core      himalaya          osinfo-db-tools   sqlx-cli
avahi             libmobi           principalmapper
==> Updated Formulae
Updated 422 formulae.
==> Renamed Formulae
grakn -> typedb
==> New Casks
adobe-dng-converter     kubenav                 usbimager
blobsaver               lightwright             wolfram-player
flomo                   prisma-studio
==> Updated Casks
Updated 224 casks.
==> Deleted Casks
appstudio               hex                     opera-mail
auristor-client         iograph                 resxtreme
cricut-design-space     itrash                  rss
filedrop                netbeans-php            wraparound

vaivailx@MacBook-Pro-2 get_started % brew install hashicorp/tap/packer
==> Installing packer from hashicorp/tap
==> Downloading https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2
#                                                                       ###
...
 100.0%
🍺  /usr/local/Cellar/packer/1.7.2: 3 files, 142.6MB, built in 20 seconds
vaivailx@MacBook-Pro-2 get_started %
```

```zsh
vaivailx@MacBook-Pro-2 get_started % packer
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build           build image(s) from template
    console         creates a console for testing variable interpolation
    fix             fixes templates from old versions of packer
    fmt             Rewrites HCL2 config files to canonical format
    hcl2_upgrade    transform a JSON template into an HCL2 configuration
    init            Install missing plugins or upgrade plugins
    inspect         see components of a template
    validate        check that a template is valid
    version         Prints the Packer version

vaivailx@MacBook-Pro-2 get_started %
```

ちゃんと入っている。

## [Build an Image](https://learn.hashicorp.com/tutorials/packer/docker-get-started-build-image?in=packer/docker-get-started)

お試し用ファイルをつくる

```zsh
vaivailx@MacBook-Pro-2 get_started % cat docker-ubuntu.pkr.hcl
packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:xenial"
  commit = true
}

build {
  sources = [
    "source.docker.ubuntu"
  ]
}

vaivailx@MacBook-Pro-2 get_started %
```

source builderを指定できる。
[このページ](https://www.packer.io/docs/builders/)でbuildできる対象一覧を見ることができる。

Get Startedに載っているDocker以外にAmazon EC2、LXD、Vagrant（box）、Azure、Google Cloud、Hyper-V、VMWare、VirtualBoxもビルドできるようだ。

あとは有志のビルダーがいくつか。

source dockerのcommitはプロビジョニングした後にイメージをコミットするか、コンテナをエクスポートするかを設定するパラメータ

## [Initialize Packer configuration
](https://learn.hashicorp.com/tutorials/packer/docker-get-started-build-image?in=packer/docker-get-started#initialize-packer-configuration)

コードを書いたら初期化する

```zsh
vaivailx@MacBook-Pro-2 get_started % packer init .
Installed plugin github.com/hashicorp/docker v0.0.7 in "/Users/vaivailx/.packer.d/plugins/github.com/hashicorp/docker/packer-plugin-docker_v0.0.7_x5.0_darwin_amd64"
vaivailx@MacBook-Pro-2 get_started %
```

なるほど、コードに指定されているプラグインがはいるのか。

## [Format and validate your Packer template](https://learn.hashicorp.com/tutorials/packer/docker-get-started-build-image?in=packer/docker-get-started#format-and-validate-your-packer-template)

goのようにfmtコマンドがあるとのこと


```
vaivailx@MacBook-Pro-2 get_started % cp docker-ubuntu.pkr.hcl{,.notfmt}
vaivailx@MacBook-Pro-2 get_started % packer fmt .
docker-ubuntu.pkr.hcl
vaivailx@MacBook-Pro-2 get_started % diff docker-ubuntu.pkr.hcl{,.notfmt}
5c5
<       source  = "github.com/hashicorp/docker"
---
>       source = "github.com/hashicorp/docker"
```

validateもできる

```
vaivailx@MacBook-Pro-2 get_started %  packer validate .
vaivailx@MacBook-Pro-2 get_started % echo $?
0
vaivailx@MacBook-Pro-2 get_started %
```

コンテナをビルドする
```zsh
vaivailx@MacBook-Pro-2 get_started % packer build docker-ubuntu.pkr.hcl
docker.ubuntu: output will be in this color.

==> docker.ubuntu: Creating a temporary directory for sharing data...
==> docker.ubuntu: Pulling Docker image: ubuntu:xenial
...
==> Builds finished. The artifacts of successful builds are:
--> docker.ubuntu: Imported Docker image: sha256:b7576f43e93cd697189cd233719b00aad926b19e7b716107abc0b8100524892b
vaivailx@MacBook-Pro-2 get_started %
```


ビルドされたイメージでコンテナを起動する
```zsh
vaivailx@MacBook-Pro-2 get_started % docker run -it sha256:b7576f43e93cd697189cd233719b00aad926b19e7b716107abc0b8100524892b
# cat /etc/os-release
NAME="Ubuntu"
VERSION="16.04.7 LTS (Xenial Xerus)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 16.04.7 LTS"
VERSION_ID="16.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
VERSION_CODENAME=xenial
UBUNTU_CODENAME=xenial
#
```

## [Provision](https://learn.hashicorp.com/tutorials/packer/docker-get-started-provision?in=packer/docker-get-started)

buildの中でprovisionを定義することでプロビジョニングができる

基本的なシェルスクリプト実行。環境変数も定義できる。

```terraform
build {
  sources = [
    "source.docker.ubuntu"
  ]
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Adding file to Docker Container",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }
}
```

```zsh
vaivailx@MacBook-Pro-2 get_started % packer build docker-ubuntu.pkr.hcldocker.ubuntu: output will be in this color.

==> docker.ubuntu: Creating a temporary directory for sharing data...
==> docker.ubuntu: Pulling Docker image: ubuntu:xenial
    docker.ubuntu: xenial: Pulling from library/ubuntu
    docker.ubuntu: Digest: sha256:9775877f420d453ef790e6832d77630a49b32a92b7bedf330adf4d8669f6600e
    docker.ubuntu: Status: Image is up to date for ubuntu:xenial
    docker.ubuntu: docker.io/library/ubuntu:xenial
==> docker.ubuntu: Starting docker container...
    docker.ubuntu: Run command: docker run -v /Users/vaivailx/.packer.d/tmp432866957:/packer-files -d -i -t --entrypoint=/bin/sh -- ubuntu:xenial
    docker.ubuntu: Container ID: 35a3d496eb85f31ba594e255a1ec3340484793b4a0f740f35c969f6da1a12e25
==> docker.ubuntu: Using docker communicator to connect: 172.17.0.2
==> docker.ubuntu: Provisioning with shell script: /var/folders/3c/93rbry1s0nq0rygk72hjrckc0000gn/T/packer-shell450905534
    docker.ubuntu: Adding file to Docker Container
==> docker.ubuntu: Committing the container
    docker.ubuntu: Image ID: sha256:6ca7f4904923691341567a06032b2e3134064e310da2452c145f79fd8e4423e9
==> docker.ubuntu: Killing the container: 35a3d496eb85f31ba594e255a1ec3340484793b4a0f740f35c969f6da1a12e25
Build 'docker.ubuntu' finished after 9 seconds 855 milliseconds.

==> Wait completed after 9 seconds 855 milliseconds

==> Builds finished. The artifacts of successful builds are:
--> docker.ubuntu: Imported Docker image: sha256:6ca7f4904923691341567a06032b2e3134064e310da2452c145f79fd8e4423e9
vaivailx@MacBook-Pro-2 get_started %
```

```zsh
vaivailx@MacBook-Pro-2 get_started % docker run -it sha256:6ca7f4904923691341567a06032b2e3134064e310da2452c145f79fd8e4423e9
# cat example.txt
FOO is hello world
#
```

## [Variable](https://learn.hashicorp.com/tutorials/packer/docker-get-started-variables?in=packer/docker-get-started)

トップレベルに`variable`で変数を定義することができる

```terraform
variable "docker_image" {
  type    = string
  default = "ubuntu:xenial"
}
```

参照は、基本的に`var.`でする。provisionerでは、`${var.}`で参照する。

```terraform
source "docker" "ubuntu" {
  image  = var.docker_image
  commit = true
}

build {
  sources = [
    "source.docker.ubuntu"
  ]
  provisioner "shell" {
    inline = ["echo Running ${var.docker_image} Docker image."]
  }
}

```

```

外部ファイルにパラメータを定義して実行時に上書きもできる
これは、開発環境、ステージング環境、本番環境ごとのパラメータや秘匿情報の設定で使えそう

```zsh
vaivailx@MacBook-Pro-2 get_started % packer build --var-file=example.pkrvars.hcl docker-ubuntu.pkr.hcl
docker.ubuntu: output will be in this color.

==> docker.ubuntu: Creating a temporary directory for sharing data...
==> docker.ubuntu: Pulling Docker image: ubuntu:bionic
    docker.ubuntu: bionic: Pulling from library/ubuntu

```

`*.auto.pkrvars.hcl`というファイル名にすると、自動的に読み込んでくれるらしい。
コマンドラインにてフラグでパラメータ指定も可能らしい。

```zsh
packer build --var docker_image=ubuntu:groovy .
```

# [aws get started](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli?in=packer/aws-get-started)


試してみる

```zsh
vaivailx@MacBook-Pro-2 packer_tutorial_aws % packer build aws-ubuntu.pkr.hcl
amazon-ebs.ubuntu: output will be in this color.

...

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
us-west-2: ami-050a406e0175ead86

vaivailx@MacBook-Pro-2 packer_tutorial_aws %

二回連続で実行してみると

```zsh
vaivailx@MacBook-Pro-2 packer_tutorial_aws % packer build aws-ubuntu.pkr.hcl
amazon-ebs.ubuntu: output will be in this color.

...

Build 'amazon-ebs.ubuntu' errored after 7 seconds 633 milliseconds: Error: AMI Name: 'learn-packer-linux-aws' is used by an existing AMI: ami-050a406e0175ead86

==> Wait completed after 7 seconds 633 milliseconds

==> Some builds didn't complete successfully and had errors:
--> amazon-ebs.ubuntu: Error: AMI Name: 'learn-packer-linux-aws' is used by an existing AMI: ami-050a406e0175ead86

==> Builds finished but no artifacts were created.
vaivailx@MacBook-Pro-2 packer_tutorial_aws %
```

AMI Nameが被るのでエラー

## [Provision](https://learn.hashicorp.com/tutorials/packer/aws-get-started-provision?in=packer/aws-get-started)

```zsh
vaivailx@MacBook-Pro-2 packer_tutorial_aws % packer build aws-ubuntu.pkr.hcl
amazon-ebs.ubuntu: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: learn-packer-linux-aws-redis

...

==> amazon-ebs.ubuntu: Connected to SSH!
==> amazon-ebs.ubuntu: Provisioning with shell script: /var/folders/3c/93rbry1s0nq0rygk72hjrckc0000gn/T/packer-shell373802359
    amazon-ebs.ubuntu: Installing Redis

...

==> amazon-ebs.ubuntu: Waiting for AMI to become ready...
==> amazon-ebs.ubuntu: Terminating the source AWS instance...
==> amazon-ebs.ubuntu: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu: No volumes to clean up, skipping
==> amazon-ebs.ubuntu: Deleting temporary security group...
==> amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu' finished after 4 minutes 1 second.

==> Wait completed after 4 minutes 1 second

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
us-west-2: ami-076815770f9a19d4a

vaivailx@MacBook-Pro-2 packer_tutorial_aws %
```

## [Varialble](https://learn.hashicorp.com/tutorials/packer/aws-get-started-variables?in=packer/aws-get-started)

以下のように変数や、関数を使って動的な値を設定することもできる。

```zsh
variable "ami_prefix" {
  type    = string
  default = "learn-packer-linux-aws-redis"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

```

上記のコードを足して、ビルドする

```zsh
vaivailx@MacBook-Pro-2 packer_tutorial_aws % packer build aws-ubuntu.pkr.hcl
amazon-ebs.ubuntu: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: learn-packer-linux-aws-redis-20210615140504
    amazon-ebs.ubuntu: Found Image ID: ami-0dd273d94ed0540c0

...

==> amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu' finished after 4 minutes 7 seconds.

==> Wait completed after 4 minutes 7 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
us-west-2: ami-0cd05190afeaaafab

vaivailx@MacBook-Pro-2 packer_tutorial_aws %
```

## [Parallel Builds](https://learn.hashicorp.com/tutorials/packer/aws-get-started-parallel-builds?in=packer/aws-get-started)

sourceブロックを足して、buildブロックのsourcesにビルド対象を追加して、
`packer build .`すると、2つのイメージをビルドできた。

```zsh
source "amazon-ebs" "ubuntu-focal" {
  ami_name      = "${var.ami_prefix}-focal-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
```

ビルド

```zsh
vaivailx@MacBook-Pro-2 packer_tutorial_aws % packer build .
amazon-ebs.ubuntu: output will be in this color.
amazon-ebs.ubuntu-focal: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: learn-packer-linux-aws-redis-20210615143312

...

==> amazon-ebs.ubuntu: Waiting for AMI to become ready...
==> amazon-ebs.ubuntu-focal: Terminating the source AWS instance...
==> amazon-ebs.ubuntu-focal: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu-focal: No volumes to clean up, skipping
==> amazon-ebs.ubuntu-focal: Deleting temporary security group...
==> amazon-ebs.ubuntu-focal: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu-focal' finished after 4 minutes 3 seconds.
==> amazon-ebs.ubuntu: Terminating the source AWS instance...
==> amazon-ebs.ubuntu: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu: No volumes to clean up, skipping
==> amazon-ebs.ubuntu: Deleting temporary security group...
==> amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu' finished after 5 minutes 46 seconds.

==> Wait completed after 5 minutes 46 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
us-west-2: ami-07122f34f64f602c4

--> amazon-ebs.ubuntu-focal: AMIs were created:
us-west-2: ami-0912c8f0fed4833a6

vaivailx@MacBook-Pro-2 packer_tutorial_aws %
```

パラレルで実行するけど、実行時間は少し延びている。

