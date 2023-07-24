# packer build of jambonz-mini VM template for Proxmox

A [packer](https://www.packer.io/) template to build an proxmox VM template containing everything needed to run jambonz on a single VM instance.  The base linux distro is Debian 11 (bullseye).

Once the VM template has been created using this template, the associated terraform template should be used to deploy the final jambonz-mini server.

## Prerequisites
In order to run this packer script you must first create a VM template on your Packer node that has a basic Debian 11 install meeting the following requirements:
- an 'admin' user has been created that has sudo privileges
- the 'admin' user should have your public ssh key installed to allow passwordless access
- the VM template should have 4 CPU cores

## Installing 

Assuming that you have created a variables.json file to hold your variable values, you would simply do this:
```
$  packer build -color=false -var-file=variables.json template.json
```

### variables
There are many variables that can be specified either on the `packer build` command line, or in a separate variables.json file.

- `proxmox_url`: the url of the proxmox GUI api server (e.g.https://<your-ip>:8006/api2/json)
- `proxmox_user`: user to log into proxmox GUI (e.g. root@pam)
- `proxmox_password`: password for proxmox GUI user
- `proxmox_node`: name of the promox node
- `proxmox_source_vm_private_key_file`: path to private ssh key on local machine, used to ssh to source vm without a password
- `proxmox_clone_vm`: name of the VM template to clone and build from
- `proxmox_vm_id`: vm id to assign to the VM build server
- `proxmox_bridge`: name of the proxmox bridge to attach the VM build server to
- `proxmox_ip`: IP address to assign to the VM build server
- `proxmox_gateway`: gateway for the VM build server
```
