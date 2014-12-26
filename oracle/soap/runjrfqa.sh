#!/bin/sh

SOAP_HOME=/scratch/doshi/workspace/soap_web_services
DIR=`pwd`

cd $SOAP_HOME
gradle clean build carbgen
cd $SOAP_HOME/itest/install-server
gradle clean devinstall
cd $SOAP_HOME/itest/jrf-ws-qa-tests
gradle clean runTests

cd $DIR
