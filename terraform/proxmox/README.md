# terraform deployment of jambonz-mini VM for Proxmox

A [terraform](https://www.terraform.io/) template to deploy a jambonz-mini server on Proxmox. The VM template should have been built using the associated packer script.

## Prerequisites
- A Proxmox jambonz-mini VM template built using the associated packer template
- A Proxmox node with two bridges: one for a private network and one for a public network

The jambonz-mini VM will attach to both networks as a dual-homed server; thus it will have both a public address (as needed to be reachable for SIP, RTP, and HTTP) as well as a private network.

## Installing

```
terraform init
```
to install the Proxmox terraform provider, then you will typically create a `terraform.tfvars` to provide variable values (they can also be provided on the command line).  One that is done, then:

```
terraform plan
```

If all looks good then

```
terraform apply
```

## Variables

- `pm_api_url`: URL of Proxmox GUI api (e.g. https://<your-ip>:8006/api2/json)
- `pm_user`: Proxmox GUI user
- `pm_password`: Proxmox GUI password
- `pm_source_template`: name of VM template (this would have been built using the packer template)
- `pm_target_node`: Proxmox node name
- `pm_storage`: storage name (e.g. "local")
- `pve_host`: IP address of Proxmox node
- `pve_user`: ssh user for Proxmox node (e.g. "root")
- `url_portal` = DNS name you will assign to the jambonz-mini VM (the jambonz portal will be served at this URL)
`ifpconfig_private`: ip and gateway for private network (e.g. "ip=10.200.100.20/24,gw=10.200.100.1")
`ifpconfig_public`: ip and gateway for public network (e.g. "ip=62.210.101.46/32,gw=62.210.0.1")
`ssh_pub_key_path`: path to your public ssh key (e.g. "~/.ssh/id_rsa.pub")
`ssh_private_key_path`: path to your private ssh key (e.g. "~/.ssh/id_rsa")