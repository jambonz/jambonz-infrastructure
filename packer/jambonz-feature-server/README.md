# packer-jambonz-mini

A [packer](https://www.packer.io/) template to build an AMI containing everything needed to run jambonz on a single EC2 instance.  The base linux distro is Debian 9 (stretch).

## Installing 

```
$  packer build -color=false template.json
```

### variables
There are many variables that can be specified on the `packer build` command line; however defaults (which are shown below) are appropriate for building an "all in one" jambonz server, so you generally should not need to specify values.

```
"region": "us-east-1"
```
The region to create the AMI in

```
"ami_description": "EC2 AMI jambonz mini"
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
