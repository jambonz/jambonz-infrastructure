# jambonz infrastructure

This repository contains [packer](packer.io) and [terraform](terraform.io) scripts for deploying jambonz on AWS hosted infrastructure.  Packer scripts build the necessary AMIs, and terraform scripts create the full AWS infrastructure using those AMIs.

A jambonz deployment provides both Session Border Controller (SBC) and feature server functionality.  If you have an existing SBC that you want to use, you can place that in front of the jambonz servers if you wish (though it is not necessary) however you must in all cases deploy both the jambonz SBC and feature server components.

There are two supported deployment configurations:

- a [devtest](./terraform/jambonz-small) deployment suitable for development and testing purposes; this configuration consists of one jambonz [SBC server](./packer/jambonz-sbc-sip-rtp) and one [feature server](./packer/jambonz-feature-server).
- a [production](./terraform/jambonz-standard) deployment; this configuration consists of two SBCs with [SIP](./packer/jambonz-sbc-sip) and [RTP](./packer/jambonz-sbc-rtp) handling separated onto different servers (i.e. 4 servers in total for SBC processing), and [feature servers](./packer/jambonz-feature-server) in an autoscale group.

#### autoscaling feature servers
Both the devtest and production deployments create a single feature server in an autoscale group.

There is initially no scaling policy applied, but after running the terraform script and creating the infrastructure you can use the AWS console to apply a scaling policy (e.g. scale up when cpu > 60%) or a schedule (e.g. run 3 feature servers during the day and only one overnight) or modify the static configuration to set the desired/min/max instances as you wish.

#### graceful scale-in
The feature servers make use of AWS SNS lifecycle notifications to scale-in gracefully, allowing calls in progress to complete before shutting down.  A maximum of 15 minutes is given for calls to complete; after that period any remaining calls will be torn down.  This duration interval can be edited in the autoscale group configuration via the AWS console or cli if desired.

#### temporarily taking a feature server out of service
If you want to temporarily take a feature server out of rotation (not receiving any calls from the SBCs), there is a two step process to do so:

1. Using the AWS console or cli, select the instance within the autoscale group and put it into Standby state.
2. Once the instance is in standby state, ssh into the instance and again send a SIGHUP signal to the node.js process running the feature server application.  This will cause the feature server to send an OPTIONS request to the SBC indicating that it is out of service.

At that point, you need to wait for any calls in progress on the feature to dry up.  Once they do, you can then perform your maintenance or troubleshooting as needed.

To bring the feature back into service once the maintenance is complete, do the following:

1. Using the AWS console or cli, select the instance within the autoscale group and put it back into the InService state.
2. Once the instance is in the InService state, ssh into the instance and send a SIGHUP signal to the node.js process running the feature server application.  This will cause the feature server to send an OPTIONS request to the SBC indicating that it is back in service.

