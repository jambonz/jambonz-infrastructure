# packer-homer

A [packer](https://www.packer.io/) template to build an AMI that runs [homer](https://github.com/sipcapture/homer) VoIP monitoring stack.  The base linux distro is Debian 10 (buster).  The packer script can build any of the following configurations:
- an "all in one" AMI that includes homer, postgresql, telegraf, influxdb, and grafana.
- a homer-only AMU that includes homer, postgresql, telegraf and sends statistics to a remote influxdb/grafana server
- an influxdb/grafana AMI that includes influxdb and grafana, receiving data from a remote homer server via telegraf

The default settings will build an all-in-one server.

Additionally, the [Node-RED](https://nodered.org) graphical application development environment can be installed as an option to any of the above configuration.  Whilst application is a distinct and seperate function from application monitoring, to reduce the number of EC2 instances it may be desirable in some installations to run Node-RED on the monitoring server.  

> For those not familiar with Node-RED, it is a low-code application develoment tool that can be used to build jambonz applications. 

## Installing 

```
$  packer build -color=false template.json -var 'homer_password=ShnqaYuivIiyd'
```
Builds an all in one AMI

```
$  packer build -color=false template.json -var 'homer_password=ShnqaYuivIiyd' \
-var 'install_influxdb=no' -var 'influxdb_ip=55.209.23.30'
```
Builds a homer-only AMI that sends data to an influxdb service at http://55.209.23.30:8086

```
$  packer build -color=false template.json -var 'homer_password=ShnqaYuivIiyd' \
-var 'install_homer=no'
```
Builds an influxdb/grafana AMI

### variables
There are many variables that can be specified on the `packer build` command line; however defaults (which are shown below) are appropriate for building an "all in one" homer server that includes influxdb and telegraf.

```
"region": "us-east-1"
```
The region to create the AMI in

```
"ami_description": "homer monitoring"
```
AMI description.

```
"instance_type": "t2.medium"
```
EC2 Instance type to use when building the AMI.

```
"homer_user": "homer_user",
```
homer username

```
"homer_password": "XcapJTqy11LnsYRtxXGPTYQkAnI",
```
homer password -- it is strongly recommended that you pass a randomly generated password as a command line variable

```
"install_nodered":  "yes"
```
whether or not to install Node-RED.

```
"install_influxdb":  "yes"
```
whether or not to install influxdb and grafana.

```
"install_homer":  "yes"
```
whether or not to install homer, postgresql and telegraf.

```
"influxdb_ip" : "127.0.0.1"
```
ip address of remote influxdb server.  This should only be specified when building a "homer-only" AMI.

```
"tag_name": "homer"
```
AWS tag Name value
