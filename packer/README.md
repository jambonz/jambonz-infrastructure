# packer scripts

[packer](https://www.packer.io/) is a tool for building machine images.  This folder contains packer templates for building AWS AMIs for running jambonz on AWS.

## Building a single "all-in-one" AMI

The [jambonz-mini](./jambonz-mini) packer template builds an AWS machine instance that contains all of the jambonz components on a single server.  A jambonz-mini system is typically used for development and testing purposes, or to run a smaller production system.

Once you have created the AMIs you can then deploy the cluster using the [jambonz-mini.yaml](../cloudformation/jambonz-mini.yaml) cloudformation script. Be sure to edit that CF script to reference your AMI ids and region in the Mappings section of the yaml document.

## Building a scalable jambonz cluster

To build a horizontally-scalable jambonz cluster you will need to build 5 distinct AWS AMIs using these packer templates:

- [jambonz-feature-server](./jambonz-feature-server)
- [jambonz-monitoring](./jambonz-monitoring)
- [jambonz-sbc-sip](./jambonz-sbc-sip)
- [jambonz-sbc-rtp](./jambonz-sbc-rtp)
- [jambonz-web-server](./jambonz-web-server)

Once you have created the AMIs you can then deploy the cluster using the [jambonz-scalable-production.yaml](../cloudformation/jambonz-scalable-production.yaml) cloudformation script. Be sure to edit that CF script to reference your AMI ids and region in the Mappings section of the yaml document.