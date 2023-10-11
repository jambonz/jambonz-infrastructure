# jambonz-feature-server

A [packer](https://www.packer.io/) template to build an AMI for the jambonz feature server.  The base linux distro is Debian 10 (buster).

## Installing 

To build a debian 11 AMI (preferred):
```
$  packer build -color=false template.json
```

To build an RHEL-9 AMI:
```
packer build -color=false -var "redhat_username=<my-rh-username>" -var "redhat_password=<my-rh-password>" template-rhel.json
```

To build an RHEL-8 AMI:
```
packer build -color=false-var "redhat_username=<my-rh-username>" -var "redhat_password=<my-rh-password>" \
-var "distro=rhel-8" -var "rhel_major_release_number=8"  template-rhel.json```

To build an arm64 image:

```
$  packer build -color=false \
--var="ami_base_image_arch=arm64" \
--var="instance_type=t4g.xlarge" \
template.json
```

### variables
There are many variables that can be specified on the `packer build` command line; however defaults (which are shown below) are appropriate for building an "all in one" jambonz server, so you generally should not need to specify values.

```
"region": "us-east-1"
```
The region to create the AMI in

```
"ami_description": "jambonz feature server"
```
AMI description.

```
"instance_type": "t2.medium"
```
EC2 Instance type to use when building the AMI.


```
"drachtio_version": "v0.8.4"
```
drachtio tag or branch to build

```
    "install_datadog": "no",
```
whether to install datadog (commercial) monitoring agent

```
    "install_telegraf": "yes",
```
whether to install telegraf (open source) monitoring agent

