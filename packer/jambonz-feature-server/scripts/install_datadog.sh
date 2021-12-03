#!/bin/bash
if [ "$1" == "yes" ]; then 
  echo installing datadog...

  DD_INSTALL_ONLY=true DD_API_KEY=your-dd-key-here bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
fi