# packer-sbc-rtp

A [packer](https://www.packer.io/) template to build an AMI for a jambonz SBC RTP server.  The base linux distro is Debian 11 (bullseye).

## Installing 

To build an amd64 image:

```
$  packer build -color=false template.json
```

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
"ami_description": "EC2 AMI jambonz mini"
```
AMI description.

```
"instance_type": "t2.medium"
```
EC2 Instance type to use when building the AMI.

```
"rtp_engine_version": "mr7.4.1.5",
```
the version of rtpengine to build

```
"rtp_engine_min_port": "40000",
"rtp_engine_max_port": "60000",
```
the port range for rtp traffic
