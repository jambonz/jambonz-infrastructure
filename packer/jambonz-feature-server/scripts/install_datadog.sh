#!/bin/bash
if [ "$DD_INSTALL" == "yes" ] && [ "$DD_KEY" != "" ]; then
  echo installing datadog...

  DD_INSTALL_ONLY=true DD_API_KEY=${DD_KEY} bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
fi