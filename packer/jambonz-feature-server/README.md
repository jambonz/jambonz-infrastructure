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
"install_drachtio": "true"
```
whether to install drachtio

```
"install_nodejs": "false",
```
whether to install Node.js

```
"install_rtpengine": "true",
```
whether to install rtpengine

```
"install_freeswitch": "true",
```
whether to install freeswitch

```
"install_drachtio_fail2ban": "true",
```
whether to install fail2ban with drachtio filter

```
"install_redis": "true",
```
whether to install redis

```
"drachtio_version": "v0.8.3"
```
drachtio tag or branch to build

```
"nodejs_version": "v10.16.2",
```
Node.js version to install

```
"freeswitch_bind_cloud_ip": "true"
```
If freeswitch is enabled, and cloud_provider is not none then this variable dictates whether freeswitch should bind its sip and rtp ports to the cloud public address (versus the local ipv4 address).

```
"mod_audio_fork_subprotocol": "audio.jambonz.org"
```
websocket subprotocol name used by freeswitch module mod_audio_fork

```
"mod_audio_fork_service_threads": "3",
```
number of libwebsocket service threads used by freeswitch module mod_audio_fork

``
"mod_audio_fork_buffer_secs": "2",
```
max number of seconds of audio to buffer by freeswitch module mod_audio_fork

```
"freeswitch_build_with_grpc:: "true"
```
whether to build support for google speech and text-to-speech services

```
"remove_source": "true"
```
whether to remove source build directories, or leave them on the instance

```
"cloud_provider": "aws"
```
Cloud provider the AMI will be built on.
