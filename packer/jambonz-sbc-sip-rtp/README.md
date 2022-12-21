# packer-jambonz-sbc-sip-rtp

**This packer script is deprecated.  If clustering, use separate amis for SBC-IP and SBC-RTP**

A [packer](https://www.packer.io/) template to build an AMI containing everything needed to run the SBC functionality of jambonz,

## Installing 

```
$  packer build -color=false template.json
```

### variables
There are many variables that can be specified on the `packer build` command line; these are shown below with their default values.

```
"region": "us-east-1"
```
The region to create the AMI in

```
"ami_description": "jambonz SBC SIP+RTP+Webserver"
```
AMI description.

```
"instance_type": "t2.xlarge"
```
EC2 Instance type to use when building the AMI.


```
"drachtio_version": "v0.8.10"
```
drachtio tag or branch to build

```

```
"rtp_engine_version": "mr9.3.1.8",
```
rtpengine version

```
"rtp_engine_min_port": "40000",
"rtp_engine_max_port": "60000"
```
rtp port range for rtpengine

```
    "install_datadog": "no",
```
whether to install datadog (commercial) monitoring agent

```
    "install_telegraf": "yes",
```
whether to install telegraf (open source) monitoring agent



