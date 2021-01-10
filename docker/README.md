# docker-compose

This folder contains a docker compose file that can be used to run a jambonz system for development purposes on your laptop or other docker machine.  It is not intended to be used for production purposes.

The docker network will include all of components of a jambonz system:
- a Session Border Controller (SBC)
- a feature server
- mysql database
- redis server
- web provisioning application

## Configuration
There are a few configuration items you will need to supply before running docker-compose:

1. A json key from google cloud to use for text-to-speech and speech-to-text.  Download the key from [GCP](https://console.cloud.google.com/) and save it as gcp.json in the [credentials subfolder](credentials/).

2. Edit the [.env](.env) file and minimally specify `HOST_IP` as the public ip address of the host machine on which you are running docker. 
>>If you are testing by using a softphone on your laptop you can simply use the loopback address; e.g. `HOST_IP=127.0.0.1`, otherwise specify the IP address that external SIP traffic will be sent to.

3. Optionally, if you want to use AWS/Polly for text-to-speech then specify your AWS credentials (access key id, secret access key, and region) in the [.env](.env) file.

## Running
Checkout and install as follows:
```
git clone git@github.com:jambonz/jambonz-infrastructure.git
cd jambonz-infrastructure
git submodule update --init
cd docker

# now copy json key to credentials/gcp.json and edit .env as described above

# now start up the docker network
docker-compose -f docker-compose.yaml up -d
```
This step will take several minutes the first time you start it as several docker images need to be downloaded and built.  Once all of the containers are running, it may take another minute for the webapp to be built and connect to the database.  

Once it does, you can log into the webapp at `localhost:3001` and configure the system.  As usual, the initial password will be admin/admin and you will be forced to change it.

You can then configure your account, applications, sip trunks and phone numbers as usual.

To stop the system, from the same directory simply run:
```
docker-compose -f docker-compose.yaml down
```

**Note**: The mysql database will be stored in the `data_volume/` subfolder that is created, so that your provisioning data will persist between restarts of the docker network.

Once you have provisioned the system, you should be able to point sip devices to register and send INVITEs to port 5060 on host ip address that you configured above and have that traffic routed to your jambonz system.

## Capacity
The system has limited capacity as it is intended to be used as a personal development / test machine.  

Specifically, the rtpengine container which is part of the SBC function is configured to handle at most 50 simultaneous calls.