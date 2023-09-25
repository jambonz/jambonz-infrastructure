#!/bin/bash
FREESWITCH_VERSION=v1.10.10
SPAN_DSP_VERSION=0d2e6ac
GRPC_VERSION=v1.57.0
GOOGLE_API_VERSION=29374574304f3356e64423acc9ad059fe43f09b5
#AWS_SDK_VERSION=1.11.143 # newer but buggy with s2n_init crashes and weird slowdown on voice playout in FS
AWS_SDK_VERSION=1.8.129
LWS_VERSION=v4.3.2
MODULES_VERSION=v0.8.4

echo "freeswitch version to install is ${FREESWITCH_VERSION}"
echo "drachtio modules version to install is ${MODULES_VERSION}"
echo "GRPC version to install is ${GRPC_VERSION}"
echo "GOOGLE_API_VERSION version to install is ${GOOGLE_API_VERSION}"
echo "AWS_SDK_VERSION version to install is ${AWS_SDK_VERSION}"
echo "LWS_VERSION version to install is ${LWS_VERSION}"

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

cd /tmp
tar xvfz SpeechSDK-Linux-1.32.1.tar.gz
cd SpeechSDK-Linux-1.32.1
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
echo remove SpeechSDK-Linux-1.32.1
sudo rm -Rf /tmp/SpeechSDK-Linux-1.32.1.tgz /tmp/SpeechSDK-Linux-1.32.1
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
git clone https://github.com/drachtio/cobalt-asr-grpc-api.git -b main
git clone https://github.com/freeswitch/spandsp.git && cd spandsp && git checkout ${SPAN_DSP_VERSION} && cd ..
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
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_cobalt_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_cobalt_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_deepgram_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_deepgram_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_ibm_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_ibm_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nuance_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nuance_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nvidia_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nvidia_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_soniox_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_soniox_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_jambonz_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_jambonz_transcribe
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_tts /usr/local/src/freeswitch/src/mod/applications/mod_google_tts
sudo cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow

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

cd /usr/local/src/freeswitch/src
echo patching switch_rtp
patch < switch_rtp.c.patch
echo patching switch_core_media
patch < switch_core_media.c.patch
cd /usr/local/src/freeswitch/src/mod/applications/mod_avmd
echo patching mod_avmd
patch < mod_avmd.c.patch
cd /usr/local/src/freeswitch/src/mod/applications/mod_httapi
echo patching mod_httapi
patch < mod_httapi.c.patch

# build libwebsockets
echo building lws
cd /usr/local/src/libwebsockets
sudo mkdir -p build && cd build && sudo cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && sudo make && sudo make install

# build libfvad
cd /usr/local/src/freeswitch/libs/libfvad
# use our version of libfvad configure.ac - should only do this on debian 12
if [ "$DISTRO" == "debian-12" ]; then
  echo "patching libfvad configure.ac to remove deprecated commands"
  sudo cp /tmp/configure.ac.libfvad configure.ac
fi
echo building libfvad
sudo autoreconf -i && sudo ./configure && sudo make -j 4 && sudo make install

# build spandsp
echo building spandsp
cd /usr/local/src/freeswitch/libs/spandsp
./bootstrap.sh && ./configure && make -j 4 && sudo make install

# build sofia
echo building sofia
cd /usr/local/src/freeswitch/libs/sofia-sip
./bootstrap.sh && ./configure && make -j 4 && sudo make install

# build aws-c-common
echo building aws-c-common
cd /usr/local/src/freeswitch/libs/aws-c-common
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter"
make -j 4 && sudo make install

# build aws-sdk-cpp
echo building aws-sdk-cpp
cd /usr/local/src/freeswitch/libs/aws-sdk-cpp
git submodule update --init --recursive
mkdir -p build && cd build
cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter"
if [ "$DISTRO" == "debian-12" ]; then
  echo "patching aws-sdk-cpp to fix debian 12 build"
  sudo sed -i 's/uint8_t arr\[16\];/uint8_t arr\[16\] = {0};/g' /usr/local/src/freeswitch/libs/aws-sdk-cpp/build/.deps/build/src/AwsCCommon/tests/byte_buf_test.c
  sudo sed -i 's/char filename_array\[64\];/char filename_array\[64\] = {0};/g' /usr/local/src/freeswitch/libs/aws-sdk-cpp/build/.deps/build/src/AwsCCommon/tests/logging/logging_test_utilities.c
  cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter"
fi
sudo make -j 4 && sudo make install
sudo find /usr/local/src/freeswitch/libs/aws-sdk-cpp/ -type f -name "*.pc" | sudo xargs cp -t /usr/local/lib/pkgconfig/

# build grpc
echo building grpc
cd /usr/local/src/grpc
git submodule update --init --recursive
mkdir -p cmake/build
cd cmake/build
cmake -DBUILD_SHARED_LIBS=ON -DgRPC_SSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ../..
make -j 4
sudo make install

# build googleapis
echo building googleapis
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

# build cobalt protobufs
echo "building protobuf stubs for cobalt"
cd /usr/local/src/freeswitch/libs/cobalt-asr-grpc-api
LANGUAGE=cpp make 

# build freeswitch
echo "building freeswitch"
cd /usr/local/src/freeswitch
sudo ./bootstrap.sh -j
sudo ./configure --enable-tcmalloc=yes --with-lws=yes --with-extra=yes --with-aws=yes
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
