#!/bin/bash
#set -eux
#Check Whether the Qualys Cloud Agent is already installed

status=$( sudo service qualys-cloud-agent status | grep running )

if [[ -z "$status" ]];
then
     # Check whether curl or wget is present in the system
     if hash curl 2>/dev/null
     then
         DOWNLOAD_CMD="curl -s --fail --retry 5 --max-time 30"
         CONSOLE_ARG=""
         TO_FILE_ARG=" -o "
         HEADER_ARG=" --head "
     else
         DOWNLOAD_CMD="wget --quiet --tries=5 --timeout=30 "
         CONSOLE_ARG=" -qO- "
         TO_FILE_ARG=" -O "
         HEADER_ARG=" -S --spider "
     fi
     # Check whether the OS is Debian or RPM based Linux and set the download location
     os=$( grep -Ei 'debian|buntu|mint' /etc/*release )
     if [[ -n "$os" || -f "/etc/debian_version" ]];
     then
         INSTALLER_FILE_URL=$arg4
         opersys="DEB"
     else
         INSTALLER_FILE_URL=$arg3
         opersys="RPM"
     fi
	 d = $RANDOM
	 mkdir -p /tmp/$d
	 cd /tmp/$d
     Downloadfile()
     {
         
		 ${DOWNLOAD_CMD} ${TO_FILE_ARG} qualys-cloud-agent.x86_64 ${INSTALLER_FILE_URL}
         if [[ $? != 0 ]];
         then
             echo "Failed to download installer from ${INSTALLER_FILE_URL}"
             exit 3
         fi
     }
     # Checks whether agent location is a FQDN or full path and invoke download or copy function 
     if [[ -n "$INSTALLER_FILE_URL" ]]; 
     then
		Downloadfile
     else
         echo "No installation path specified for Qualys Cloud Agent"
             exit 4
     fi
     if [ "$opersys" = "RPM" ];
     then
                 sleep 5
                 sudo rpm -ivh /tmp/$d/qualys-cloud-agent.x86_64
                 sleep 5
                 sudo /usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=$arg1 CustomerId=$arg2
     else
         sudo dpkg --install /tmp/$d/qualys-cloud-agent.x86_64
         sleep 5
         sudo /usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=$arg1 CustomerId=$arg2
     fi
else
	echo "QualysCloudAgent is already installed on this and running"
fi 