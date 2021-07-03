# terraform for a 2-instance jambonz system

This terraform configuration generates a jambonz deployment suitable for testing or small production loads.

The deployment generated consists of:

- a VPC along with public subnets, internet gateway, routing table and the like.
- 2 EC2 instances: 1 Session Border Controller (SBC) and 1 feature server (FS)
- an EIP (elastic IP) for the SBC instance
- an autoscale group containing the FS instance, allowing for horizontal scaling of the FS
- an SNS topic that is used to notify autoscale lifecycle events to the FS instance(s)
- an aurora mysql serverless database
- an elasticache redis server

## Running the script

### Prerequisites

Before running the terraform script you need to create amis for the SBC and the Feature server by running the [jambonz-sbc-sip-rtp](../../packer/jambonz-sbc-sip-rtp) and [jambonz-feature-server](../../packer/jambonz-feature-server) packer scripts.

Please refer to the above packer scripts for generating your AMIs.

### It's go time!

After [installing terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) install the dependencies on your local machine:

```
terraform init
```

At that point you are ready to run the script.  There are a couple of variables that you must supply, and some others that are optional.  These variables can either be defined by editing the [./variables.tf] file or supplied on the command line in `var='variable=value'` format.

|Variable Name|Value|Required?|Default Value|
|-----|----|------|-----|
|ami_owner_account|your aws account id|Yes|None|
|key_name|name of existing aws key-pair to use to access the instances (e.g. my-keypair)|Yes|None|
|ssh_key_path|path to key-pair file on local machine (e.g. ~/credentials/my-keypair.pem)|Yes|None|
|region|AWS region to create instances in|No|us-west-1|
|ec2_instance_type_sbc|EC2 instance type for SBC|No|t3.medium|
|ec2_instance_type_fs|EC2 instance type for Feature Server|No|t3.medium|
|vpc_cidr_block|Network CIDR for the created VPC|No|172.31.0.0/16|
|public_subnets|Two public subnets to create within the VPC|No|{"us-west-1a" = "172.31.32.0/24""us-west-1b" = "172.31.33.0/24"}|
|cluster_id|short identifier used to prefix some names of created items|No|jb|
|prefix|name of VPC|No|jambonz|

A command line with variables supplied looks like this:

```
terraform apply \
-var='ami_owner_account=376029039784' \
-var='region=us-west-1' \
-var='public_subnets={"us-west-1a" = "172.31.32.0/24","us-west-1b" = "172.31.33.0/24"}' \
-var='ssh_key_path=~/aws/~/aws/aws-drachtio-us-west-1.pem' \
-var='key_name=aws-drachtio-us-west-1' 
```

Enter 'yes' at the confirmation prompt, and very shortly you will be the proud owner of a brand-new jambonz cluster!

(Note: to destroy the cluster, simply run `terraform destroy` with the same command line arguments).

### Access the jambonz portal

After creating the cluster, wait a few minutes before accessing the jambonz portal for the first time.  There are some userdata scripts that need to finish running, and you may get a "502 Bad Gateway" error if you attempt to access the portal before they have completed.  If this happens, simply wait a few minutes and try again.

Once the SBC instance is fully up, log into the jambonz portal by navigating to `http://eip-of-sbc-instance` in your web browser.
 
Log in the first time with username and password 'admin'.  You will then be forced to set a new password.
 
