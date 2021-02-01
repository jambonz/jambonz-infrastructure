#!/bin/bash
VERSION=v1.10.5
GRPC_VERSION=v1.24.2
GOOGLE_API_VERSION=v1p1beta1-speech
AWS_SDK_VERSION=1.8.129

echo "freeswitch version to install is ${VERSION}"
echo "GRPC version to install is ${GRPC_VERSION}"
echo "GOOGLE_API_VERSION version to install is ${GOOGLE_API_VERSION}"
echo "AWS_SDK_VERSION version to install is ${AWS_SDK_VERSION}"

git config --global pull.rebase true
cd /usr/local/src
git clone https://github.com/signalwire/freeswitch.git -b ${VERSION}
git clone https://github.com/warmcat/libwebsockets.git -b v3.2.0
git clone https://github.com/davehorton/drachtio-freeswitch-modules.git -b master
git clone https://github.com/grpc/grpc -b ${GRPC_VERSION}

cd freeswitch/libs

git clone https://github.com/freeswitch/spandsp.git -b master
git clone https://github.com/freeswitch/sofia-sip.git -b master
git clone https://github.com/dpirch/libfvad.git
git clone https://github.com/aws/aws-sdk-cpp.git -b ${AWS_SDK_VERSION}
git clone https://github.com/davehorton/googleapis -b ${GOOGLE_API_VERSION}
git clone https://github.com/awslabs/aws-c-common.git

sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_aws_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_lex /usr/local/src/freeswitch/src/mod/applications/mod_aws_lex
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_tts /usr/local/src/freeswitch/src/mod/applications/mod_google_tts
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow
 
sudo sed -i -r -e 's/(.*AM_CFLAGS\))/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am
sudo sed -i -r -e 's/(.*-std=c++11)/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am

# build libwebsockets
cd /usr/local/src/libwebsockets
sudo mkdir -p build && cd build && sudo cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && sudo make && sudo make install

# build libfvad
cd /usr/local/src/libfvad
sudo autoreconf -i && sudo ./configure && sudo make -j 4 && sudo make install

# build spandsp
cd /usr/local/src/freeswitch/libs/spandsp
./bootstrap.sh && ./configure && make -j 4 && sudo make install

# build sofia
cd /usr/local/src/freeswitch/libs/sofia-sip
./bootstrap.sh && ./configure && make -j 4 && sudo make install

# build aws-c-common
cd /usr/local/src/freeswitch/libs/aws-c-common
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter"
make -j 4 && sudo make install

# build aws-sdk-cpp
cd /usr/local/src/freeswitch/libs/aws-sdk-cpp
mkdir -p build && cd build
cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter"
make -j 4 && sudo make install

# build grpc
cd /usr/local/src/grpc
git submodule update --init --recursive
cd /usr/local/src/grpc/third_party/protobuf
./autogen.sh
./configure
sudo make -j 4 install 
cd /usr/local/src/grpc
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
make -j 4
sudo make install

# build googleapis
cd /usr/local/src/freeswitch/libs/googleapis
LANGUAGE=cpp make -j 4

# copy Makefiles into place
cp /tmp/configure.ac.extra /usr/local/src/freeswitch/configure.ac
cp /tmp/Makefile.am.extra /usr/local/src/freeswitch/Makefile.am
cp /tmp/modules.conf.in.extra /usr/local/src/freeswitch/build/modules.conf.in
cp /tmp/modules.conf.vanilla.xml.extra /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml
cp /tmp/switch_rtp.c.patch /usr/local/src/freeswitch/src

# patch freeswitch
cd /usr/local/src/freeswitch/src
patch < switch_rtp.c.patch

# build freeswitch
echo "building freeswitch"
cd /usr/local/src/freeswitch
sudo ./bootstrap.sh -j
sudo ./configure --with-lws=yes --with-extra=yes
sudo make -j 4
sudo make install
sudo make cd-sounds-install cd-moh-install
sudo cp /tmp/acl.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/event_socket.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/conference.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo rm -Rf /usr/local/freeswitch/conf/dialplan/*
sudo rm -Rf /usr/local/freeswitch/conf/sip_profiles/*
sudo cp /tmp/mrf_dialplan.xml /usr/local/freeswitch/conf/dialplan
sudo cp /tmp/mrf_sip_profile.xml /usr/local/freeswitch/conf/sip_profiles
sudo cp /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml /usr/local/freeswitch/conf/autoload_configs
sudo cp /tmp/freeswitch.service /etc/systemd/system
sudo chown root:root -R /usr/local/freeswitch
sudo chmod 644 /etc/systemd/system/freeswitch.service
sudo sed -i -e 's/global_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/global_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml
sudo sed -i -e 's/outbound_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/outbound_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml
sudo systemctl enable freeswitch
sudo cp /tmp/freeswitch_log_rotation /etc/cron.daily/freeswitch_log_rotation
sudo chown root:root /etc/cron.daily/freeswitch_log_rotation
sudo chmod a+x /etc/cron.daily/freeswitch_log_rotation
