# jambonz-mini

A "jambonz-mini" system is the smallest/cheapest possible system.  It consists of a single server, and associated services.  Because it does not have any redundancy, it is mainly useful for testing purposes.

There are two components for deploying a jambonz mini system:
- an [AMI](./packer) for the jambonz server, and
- a [terraform script](./terraform) for creating a VPC and all associated services that are required.