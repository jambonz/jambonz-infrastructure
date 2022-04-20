# jambonz infrastructure

This repository contains [packer](packer.io) and Cloudformation templates for deploying jambonz on AWS EC2 based instances.  For deploying jambonz on Kubernetes, please refer to the [jambonz helm chart repo](https://github.com/jambonz/helm-charts).

There are two supported deployment configurations:

- a [jambonz-mini](./packer/jambonz-mini) deployment which is an "all-in-one" deployment of jambonz on a single EC2 instance.  This type of deployment is ideal for development and testing, as well as running smaller production loads.
- a production deployment which deploys jambonz in a horizontally-scalable cluster using autoscale groups.  For this deployment, [5 different packer scripts](./packer) are provided to build the 5 AMIs that are needed, and a [cloudformation script](./cloudformation/jambonz-scalable-production.yaml) script is provided to deploy them and create the supporting VPC, subnets, etc.
