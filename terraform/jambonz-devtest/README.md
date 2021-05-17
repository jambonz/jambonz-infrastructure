# terraform for a jambonz development / test system

This terraform configuration generates a jambonz deployment suitable for testing or small production deployments.

The deployment generated consists of:

- a VPC along with public subnets, internet gateway, routing table and the like.
- 2 EC2 instances: 1 SBC and 1 feature server (the SBC is assigned an elastic IP)
- an autoscale group containing the feature server
- an SNS topic that is used to notify autoscale lifecycle events to the feature server
- an aurora mysql serverless database
- an elasticache redis server

## Running the script

### Prerequisites

Before running the terraform script you will need to have done the following:

1. Provisioned accounts on AWS and GCP
1. (AWS) Created a keypair in your target region and downloaded the .pem file to your local machine.
1. (AWS) Generated an access key id and secret access key
1. (GCP) Created a project, enabled both text to speech and speech to text APIs, created a service account for the project and downloaded the json key file for the service account.
1. Copied the the GCP json key file into the `credentials\` folder in your local copy of this project.
1. Reviewed and edited the [variables.tf](./variables.tf) file in your local copy of this project to specify your desired AWS region, availability zones, EC2 instance type, and your AWS keys (alternatively, these can be specified on the command line when running the script).

### It's go time!

After [installing terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) install the dependencies on your local machine:

```
terraform init
```

Testing out the script is a good idea, particularly if you've made changes:
```
terraform plan
```

When you are ready to run it, do terraform apply, optionally passing any command-line arguments that you want to override variables.tf.

So, if you edit variables.tf to put in your selections:

```
terraform apply 
```

or, if you prefer command-line arguments, you might do:

```
terraform apply \
-var='region=eu-west-3' \
-var='public_subnets={"eu-west-3a": "172.31.32.0/24", "eu-west-3b": "172.31.33.0/24"}' \
-var='aws_access_key_id_runtime=XXXX' \
-var='aws_secret_access_key_runtime=YYYYY' \
-var='ssh_key_path=~/aws/aws-dhorton-paris.pem' \
-var='key_name=aws-dhorton-paris'
```

Enter 'yes' at the confirmation prompt, and very shortly you will be the proud owner of a brand-new jambonz cluster!

(Note: to destroy the cluster, simply run `terraform destroy`).

### Next steps

After creating the cluster, get the elastic IP of your SBC server and navigate to:

```
http://your-elastic-ip:3001
```
 in your web browser to bring up the provisioning GUI.  
 
 Log in with admin/admin.
 
 You'll be asked to change the password and then walked through a simple configuration of your account, applications, sip trunks and phone numbers.  
 
 Once done, you are ready to test!

