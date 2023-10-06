# packer-jambonz-mini

A [packer](https://www.packer.io/) template to build an AMI containing everything needed to run jambonz on a single EC2 instance.  The base linux distro is Debian 11 (bullseye).

## Installing 

To build a debian 11 AMI (preferred):
```
$  packer build -color=false template.json
```

To build an RHEL-8 AMI:
```
packer build -color=false -var "<redhat_username=my-rh-username>" -var "redhat_password=<my-rh-password>" template-rhel-8.json
```

To build an RHEL-9 AMI:
```
packer build -color=false -var "<redhat_username=my-rh-username>" -var "redhat_password=<my-rh-password>" template-rhel-9.json
```
> Note: on RHEL-9 the kernel module for rtpengine (which passes media streams in the kernel rather than userspace) is not available.  For that reason, you may prefer to deploy on RHEL-8 when deploying on RedHat Enterprise Linux.

### variables
There are many variables that can be specified on the `packer build` command line; please check the templates to see the full list.

