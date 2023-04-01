#!/bin/bash
FREESWITCH_VERSION=v1.10.5
GRPC_VERSION=c66d2cc
#GRPC_VERSION=v1.39.1
#GOOGLE_API_VERSION=v1p1beta1-speech
GOOGLE_API_VERSION=e9da6f8b469c52b83f900e820be30762e9e05c57
AWS_SDK_VERSION=1.8.129
LWS_VERSION=v3.2.3
MODULES_VERSION=v0.6.12

echo "freeswitch version to install is ${FREESWITCH_VERSION}"
echo "drachtio modules version to install is ${MODULES_VERSION}"
echo "GRPC version to install is ${GRPC_VERSION}"
echo "GOOGLE_API_VERSION version to install is ${GOOGLE_API_VERSION}"
echo "AWS_SDK_VERSION version to install is ${AWS_SDK_VERSION}"
echo "LWS_VERSION version to install is ${LWS_VERSION}"

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

cd /tmp
tar xvfz SpeechSDK-Linux-1.26.0.tar.gz
cd SpeechSDK-Linux-1.26.0
sudo cp -r include /usr/local/include/MicrosoftSpeechSDK
sudo cp -r lib/ /usr/local/lib/MicrosoftSpeechSDK
if [ "$ARCH" == "arm64" ]; then
  echo installing Microsoft arm64 libs...
  sudo cp /usr/local/lib/MicrosoftSpeechSDK/arm64/libMicrosoft.*.so /usr/local/lib/
  echo done
fi 
if [ "$ARCH" == "amd64" ]; then
  echo installing Microsoft x64 libs...
  sudo cp /usr/local/lib/MicrosoftSpeechSDK/x64/libMicrosoft.*.so /usr/local/lib/
  echo done
fi

cd /usr/local/src
echo remove SpeechSDK-Linux-1.24.2
sudo rm -Rf /tmp/SpeechSDK-Linux-1.24.2.tgz /tmp/SpeechSDK-Linux-1.24.2
echo done

echo config git
git config --global pull.rebase true
echo done
git clone https://github.com/signalwire/freeswitch.git -b ${FREESWITCH_VERSION}
git clone https://github.com/warmcat/libwebsockets.git -b ${LWS_VERSION}
git clone https://github.com/drachtio/drachtio-freeswitch-modules.git -b ${MODULES_VERSION}
git clone https://github.com/grpc/grpc -b master
cd grpc && git checkout ${GRPC_VERSION} && cd ..

cd freeswitch/libs
git clone https://github.com/drachtio/nuance-asr-grpc-api.git -b main
git clone https://github.com/drachtio/riva-asr-grpc-api.git -b main
git clone https://github.com/drachtio/soniox-asr-grpc-api.git -b main
git clone https://github.com/freeswitch/spandsp.git -b master
git clone https://github.com/freeswitch/sofia-sip.git -b master
git clone https://github.com/dpirch/libfvad.git
git clone https://github.com/aws/aws-sdk-cpp.git -b ${AWS_SDK_VERSION}
git clone https://github.com/googleapis/googleapis -b master 
cd googleapis && git checkout ${GOOGLE_API_VERSION} && cd ..
git clone https://github.com/awslabs/aws-c-common.git

sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_aws_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_azure_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_azure_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_lex /usr/local/src/freeswitch/src/mod/applications/mod_aws_lex
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_deepgram_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_deepgram_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_ibm_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_ibm_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nuance_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nuance_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nvidia_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nvidia_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_soniox_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_soniox_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_jambonz_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_jambonz_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_tts /usr/local/src/freeswitch/src/mod/applications/mod_google_tts
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow
 
sudo sed -i -r -e 's/(.*AM_CFLAGS\))/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am
sudo sed -i -r -e 's/(.*-std=c++11)/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am

# copy Makefiles and patches into place
cp /tmp/configure.ac.extra /usr/local/src/freeswitch/configure.ac
cp /tmp/Makefile.am.extra /usr/local/src/freeswitch/Makefile.am
cp /tmp/modules.conf.in.extra /usr/local/src/freeswitch/build/modules.conf.in
cp /tmp/modules.conf.vanilla.xml.extra /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml
cp /tmp/avmd.conf.xml /usr/local/src/freeswitch/conf/vanilla/autoload_configs/avmd_conf.xml
cp /tmp/switch_rtp.c.patch /usr/local/src/freeswitch/src
cp /tmp/switch_core_media.c.patch /usr/local/src/freeswitch/src
cp /tmp/mod_avmd.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_avmd
cp /tmp/mod_httapi.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_httapi

# patch freeswitch
cd /usr/local/src/freeswitch/src
patch < switch_rtp.c.patch
patch < switch_core_media.c.patch
cd /usr/local/src/freeswitch/src/mod/applications/mod_avmd
patch < mod_avmd.c.patch
cd /usr/local/src/freeswitch/src/mod/applications/mod_httapi
patch < mod_httapi.c.patch

# build libwebsockets
cd /usr/local/src/libwebsockets
sudo mkdir -p build && cd build && sudo cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && sudo make && sudo make install

# build libfvad
cd /usr/local/src/freeswitch/libs/libfvad
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
mkdir -p cmake/build
cd cmake/build
cmake -DBUILD_SHARED_LIBS=ON -DgRPC_SSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ../..
make -j 4
sudo make install

# build googleapis
cd /usr/local/src/freeswitch/libs/googleapis
echo "Ref: https://github.com/GoogleCloudPlatform/cpp-samples/issues/113"
sed -i 's/\$fields/fields/' google/maps/routes/v1/route_service.proto
sed -i 's/\$fields/fields/' google/maps/routes/v1alpha/route_service.proto
LANGUAGE=cpp make -j 4

# build nuance protobufs
echo "building protobuf stubs for Nuance asr"
cd /usr/local/src/freeswitch/libs/nuance-asr-grpc-api
LANGUAGE=cpp make 

# build nvidia protobufs
echo "building protobuf stubs for nvidia riva asr"
cd /usr/local/src/freeswitch/libs/riva-asr-grpc-api
LANGUAGE=cpp make 

# build soniox protobufs
echo "building protobuf stubs for sonioxasr"
cd /usr/local/src/freeswitch/libs/soniox-asr-grpc-api
LANGUAGE=cpp make 

# build freeswitch
echo "building freeswitch"
cd /usr/local/src/freeswitch
sudo ./bootstrap.sh -j
sudo ./configure --enable-tcmalloc=yes --with-lws=yes --with-extra=yes
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

echo "downloading soniox root verification certificate"
cd /usr/local/freeswitch/certs
wget https://raw.githubusercontent.com/grpc/grpc/master/etc/roots.pem

