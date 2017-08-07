#!/bin/bash

UBUNTU_JAVA=$(cat Dockerfile | grep docker-ubuntu-java)
if [[ $UBUNTU_JAVA == *"docker-ubuntu-java"* ]]; then
      echo $UBUNTU_JAVA | sed 's/.*://'
else
	    UBUNTU_JAVA=$(cat Dockerfile | grep JAVA_VERSION)
			echo $UBUNTU_JAVA | sed 's/.*=//' | sed 's/.$//'
fi
