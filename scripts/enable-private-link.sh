#!/bin/sh

# Copyright (C) 2018 Expedia Inc.
# Licensed under the Apache License, Version 2.0 (the "License");

set -e 
vpc_endpoint=`aws ec2 describe-vpc-endpoint-service-configurations|jq -r ".ServiceConfigurations[]|select(.NetworkLoadBalancerArns[]|contains(\"$1\")).ServiceId"`
if [ x"$vpc_endpoint" = x"" ]; then
    aws ec2 create-vpc-endpoint-service-configuration --no-acceptance-required --network-load-balancer-arns $1
    vpc_endpoint=`aws ec2 describe-vpc-endpoint-service-configurations|jq -r ".ServiceConfigurations[]|select(.NetworkLoadBalancerArns[]|contains(\"$1\")).ServiceId"`
fi

echo $2|tr "," "\n"|while read account
do
    echo "$vpc_endpoint , $account"
    aws ec2 modify-vpc-endpoint-service-permissions --service-id $vpc_endpoint --add-allowed-principals "[\"arn:aws:iam::${account}:root\"]"
done
