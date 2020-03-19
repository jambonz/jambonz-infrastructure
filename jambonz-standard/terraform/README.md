# terraform for a jambonz "standard" system

This terraform configuration generates a jambonz deployment suitable for production.  It creates a VPC with two public subnets in two availability zones for redundancy.  Each subnet contains three instances:

- an SBC SIP server
- an SBC media server
- a feature server

Each instance is assigned an elastic IP.

It also creates an Elasticache redis instance and an Aurora serverless mysql database, along with the necessary security groups.

## Before running the terraform script

There are several changes you will need to make before running the script.


1.  This script creates a VPC in the us-east-1 region.  You may prefer to run in a different region: if so, edit the variables.tf file accordingly.

2.  If you _do_ want to run in a different region, you need to make sure the 3 AMIs that the terraform script deploys are available in your preferred region. That means either you run the packer scripts yourself and create the AMIs, or you contact me and ask me to copy the AMIs into your preferred region.  If you create the AMIs yourself you will need to change the "owner" attribute in the ami filter in jambonz.tf to your own aws id.

3.  Note that the default instance size in variables.tf is a tiny t2.micro.  This is not suitable for production, but is configured that way since you may want to play with this script a bit before deploying "for real" and this will keep your costs down.  When you are ready to create your production VPC update variables.tf to choose a production quality instance type (a c5n.xlarge is a good choice).

4.  You will need to download a json service key file from google cloud in order to use the speech services.  Copy that file into the credentials folder in this project with the name gcp.json before you run terraform, since that is where the terraform script expects to find it and what it expects to be named.

5.  Also create an AWS access key id and secret access key in order to use AWS polly.  Either provide these in the variables.tf file or override on the command line.

In general, feel free to customize the terraform scripts to your needs.  They are documented and fairly self-explanatory.

## Running the terraform script

Please review and edit the [variables.tf](./variables.tf) file as appropriate, given the suggestions above.  

Then install the depedencies:
```
terraform init
```

If you've made changes to the script, test it out:
```
terraform plan
```

When you are ready to run it, do terraform apply, optionally passing any command-line arguments that you want to override variables.tf:
```
terraform apply -var='key_name=aws-dhorton-key' \
-var 'aws_access_key_id_runtime=KASYJH6IPHQPOLMVLWID' \
-var 'aws_secret_access_key_runtime=WkjfaufgzHSHDYKQ+/+1tMPO4/DM9ADWO+asdfasdf'
```

(Note: those are not valid keys of course, just for explanatory purposes).
