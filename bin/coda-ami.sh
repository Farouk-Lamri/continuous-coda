#!/usr/bin/env bash

if [ $# -lt 2 ]
then
  echo -e "too few arguments!\n"
  echo -e "  coda-ami.sh <version> <profile>"
  exit 128
fi

version=$1
profile=$2

aws --profile $2 ec2 describe-images --filters Name=name,Values=coda-${version} \
--query 'Images[0].ImageId' --output text
