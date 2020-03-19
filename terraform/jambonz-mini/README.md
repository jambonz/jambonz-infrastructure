# terraform for a jambonz dev system

This terraform configuration a small jambonz platform suitable for testing and development.  It consists of a single jambonz server providing both the SBC and feature server functionality.  In addition to the jambonz server itself, this terraform script also creates:

- a VPC that contains all of the infrastructure
- a public subnet in the VPC (including an internet gateway and route table)
- security groups to allow only appropriate traffic
- an Elasticache redis instance
- an Aurora serverless mysql database.

The jambonz instance is based on an AMI that is created from [this packer script](../packer).

## Running the terraform script

Please review and edit the [variables.tf](./variables.tf) file as appropriate.  

Then install the depdencies:
```
terraform init
```

Next, jambonz will need a google json key file as well as AWS credentials for text-to-speech.  Download a json key file form gcp and copy it into the `./credentials` folder as `gcp.json`.  

Finally, apply the terraform configuration, passing the AWS credentials on the command line:

```
terraform apply -var='key_name=<your-aws-key-name>' \
-var 'aws_access_key_id_runtime=<your aws access key for tts>' \
-var 'aws_secret_access_key_runtime=<your aws secret access key for tts>'
```
