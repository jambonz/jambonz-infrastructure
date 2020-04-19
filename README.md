# jambonz infrastructure

This repository contains [packer](packer.io) and [terraform](terraform.io) scripts for deploying jambonz on AWS hosted infrastructure.  Packer scripts build the necessary AMIs, and terraform scripts create the full AWS infrastructure using those AMIs.

There are 3 different deployment alternatives:

- a ["jambonz mini"](./terraform/jambonz-mini) deployment, consisting of a [single server](./packer/jambonz-mini)
- a ["jambonz small"](./terraform/jambonz-small) deployment, consisting of one server for [SBC functionality](./packer/jambonz-sbc-sip-rtp) and a second server for [feature server functionality](./packer/jambonz-feature-server).
- a ["jambonz standard"](./terraform/jambonz-standard) deployment, which provides redundancy and scalability and a fully-exploded functional architecture consisting instances for [SBC SIP signaling](./packer/jambonz-sbc-sip), a second set of instance for [SBC media handling](./packer/jambonz-sbc-rtp), and a third set of instances for [feature server](./packer/jambonz-feature-server).

