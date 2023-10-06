#!/bin/bash

DISTRO=$1

FREESWITCH_VERSION=v1.10.10
SPAN_DSP_VERSION=0d2e6ac
GRPC_VERSION=v1.57.0
GOOGLE_API_VERSION=29374574304f3356e64423acc9ad059fe43f09b5
#AWS_SDK_VERSION=1.11.143 # newer but buggy with s2n_init crashes and weird slowdown on voice playout in FS
AWS_SDK_VERSION=1.8.129
LWS_VERSION=v4.3.2
MODULES_VERSION=v0.8.4

if [ "$EUID" -ne 0 ]; then
  echo "Switching to root user..."
  bash "$0" --as-root
  exit
fi

# Your script continues here, as root
echo "freeswitch version to install is ${FREESWITCH_VERSION}"
echo "drachtio modules version to install is ${MODULES_VERSION}"
echo "GRPC version to install is ${GRPC_VERSION}"
echo "GOOGLE_API_VERSION version to install is ${GOOGLE_API_VERSION}"
echo "AWS_SDK_VERSION version to install is ${AWS_SDK_VERSION}"
echo "LWS_VERSION version to install is ${LWS_VERSION}"
echo "DISTRO is ${DISTRO}"

export PATH=/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH
if [ -n "$PKG_CONFIG_PATH" ]; then
  export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
else
  export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
fi


cd /tmp
tar xvfz SpeechSDK-Linux-1.32.1.tar.gz
cd SpeechSDK-Linux-1.32.1
cp -r include /usr/local/include/MicrosoftSpeechSDK
cp -r lib/ /usr/local/lib/MicrosoftSpeechSDK
if [ "$ARCH" == "arm64" ]; then
  echo installing Microsoft arm64 libs...
  cp /usr/local/lib/MicrosoftSpeechSDK/arm64/libMicrosoft.*.so /usr/local/lib/
  echo done
fi 
if [ "$ARCH" == "amd64" ]; then
  echo installing Microsoft x64 libs...
  cp /usr/local/lib/MicrosoftSpeechSDK/x64/libMicrosoft.*.so /usr/local/lib/
  echo done
fi

cd /usr/local/src
echo remove SpeechSDK-Linux-1.32.1
rm -Rf /tmp/SpeechSDK-Linux-1.32.1.tgz /tmp/SpeechSDK-Linux-1.32.1
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

cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_aws_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_azure_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_azure_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_lex /usr/local/src/freeswitch/src/mod/applications/mod_aws_lex
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_cobalt_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_cobalt_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_deepgram_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_deepgram_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_ibm_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_ibm_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nuance_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nuance_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nvidia_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nvidia_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_soniox_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_soniox_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_jambonz_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_jambonz_transcribe
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_tts /usr/local/src/freeswitch/src/mod/applications/mod_google_tts
cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow

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
mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && make install

# build libfvad
cd /usr/local/src/freeswitch/libs/libfvad
# use our version of libfvad configure.ac - should only do this on debian 12
if [ "$DISTRO" == "debian-12" ]; then
  echo "patching libfvad configure.ac to remove deprecated commands"
  cp /tmp/configure.ac.libfvad configure.ac
fi
echo building libfvad
autoreconf -i && ./configure && make -j 4 && make install

# build spandsp
echo building spandsp
cd /usr/local/src/freeswitch/libs/spandsp
./bootstrap.sh && ./configure && make -j 4 && make install

# build sofia
echo building sofia
cd /usr/local/src/freeswitch/libs/sofia-sip
./bootstrap.sh && ./configure && make -j 4 && make install

# build aws-c-common
echo building aws-c-common
cd /usr/local/src/freeswitch/libs/aws-c-common
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter"
make -j 4 && make install

# build aws-sdk-cpp
echo building aws-sdk-cpp
cd /usr/local/src/freeswitch/libs/aws-sdk-cpp
git submodule update --init --recursive
mkdir -p build && cd build
cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter -Wno-error=nonnull -Wno-error=deprecated-declarations -Wno-error=uninitialized -Wno-error=maybe-uninitialized"
if [ "$DISTRO" == "debian-12" ] ||[[ "$DISTRO" == rhel* ]] ; then
  echo "patching aws-sdk-cpp to fix warnings treated as errors"
  sed -i 's/uint8_t arr\[16\];/uint8_t arr\[16\] = {0};/g' /usr/local/src/freeswitch/libs/aws-sdk-cpp/build/.deps/build/src/AwsCCommon/tests/byte_buf_test.c
  sed -i 's/char filename_array\[64\];/char filename_array\[64\] = {0};/g' /usr/local/src/freeswitch/libs/aws-sdk-cpp/build/.deps/build/src/AwsCCommon/tests/logging/logging_test_utilities.c
  echo "re-running cmake after patching aws-sdk-cpp"
  cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter -Wno-error=nonnull -Wno-error=deprecated-declarations -Wno-error=uninitialized -Wno-error=maybe-uninitialized"
  echo cmake completed
fi
make -j 4 && make install
find /usr/local/src/freeswitch/libs/aws-sdk-cpp/ -type f -name "*.pc" | xargs cp -t /usr/local/lib/pkgconfig/

# build grpc
echo building grpc
cd /usr/local/src/grpc
git submodule update --init --recursive
mkdir -p cmake/build
cd cmake/build
cmake -DBUILD_SHARED_LIBS=ON -DgRPC_SSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ../..
make -j 4
make install

# build googleapis
echo building googleapis
cd /usr/local/src/freeswitch/libs/googleapis
echo "Ref: https://github.com/GoogleCloudPlatform/cpp-samples/issues/113"
sed -i 's/\$fields/fields/' google/maps/routes/v1/route_service.proto
sed -i 's/\$fields/fields/' google/maps/routes/v1alpha/route_service.proto
if [ "$DISTRO" == "debian-12" ] || [ "$DISTRO" == rhel* ] ; then
  LANGUAGE=cpp FLAGS+='--experimental_allow_proto3_optional' make -j 4
else
  LANGUAGE=cpp make -j 4
fi

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
./bootstrap.sh -j
./configure --enable-tcmalloc=yes --with-lws=yes --with-extra=yes --with-aws=yes
make -j 8
make install
make cd-sounds-install cd-moh-install
cp /tmp/acl.conf.xml /usr/local/freeswitch/conf/autoload_configs
cp /tmp/event_socket.conf.xml /usr/local/freeswitch/conf/autoload_configs
cp /tmp/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs
cp /tmp/conference.conf.xml /usr/local/freeswitch/conf/autoload_configs
rm -Rf /usr/local/freeswitch/conf/dialplan/*
rm -Rf /usr/local/freeswitch/conf/sip_profiles/*
cp /tmp/mrf_dialplan.xml /usr/local/freeswitch/conf/dialplan
cp /tmp/mrf_sip_profile.xml /usr/local/freeswitch/conf/sip_profiles
cp /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml /usr/local/freeswitch/conf/autoload_configs

if [[ "$DISTRO" == rhel* ]]; then
  cp /tmp/freeswitch-rhel.service /etc/systemd/system/freeswitch.service
else
  cp /tmp/freeswitch.service /etc/systemd/system
fi
chown root:root -R /usr/local/freeswitch
chmod 644 /etc/systemd/system/freeswitch.service
sed -i -e 's/global_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/global_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml
sed -i -e 's/outbound_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/outbound_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml
systemctl enable freeswitch
cp /tmp/freeswitch_log_rotation /etc/cron.daily/freeswitch_log_rotation
chown root:root /etc/cron.daily/freeswitch_log_rotation
chmod a+x /etc/cron.daily/freeswitch_log_rotation

echo "downloading soniox root verification certificate"
cd /usr/local/freeswitch/certs
wget https://raw.githubusercontent.com/grpc/grpc/master/etc/roots.pem
