
GREEN = \033[0;32m
YELLOW = \x1b[33m
NC = \033[0m

env?=prod

appName?=Coda
CodaVersion?=dev-master
BastionVersion?=dev-master

region?=us-east-1
stack_name?=$(appName)-$(env)
KeyName?=code-infra-test
#KeyName?=$(appName)-$(env)
#profile?=$(appName)-$(env)-cloudformation
profile?=coda
account_id?=327249545079
#BastionAmiId?=$(shell ./bin/bastion-ami.sh $(BastionVersion) $(profile))
#CodaAmiId?=$(shell ./bin/coda-ami.sh $(CodaVersion) $(profile))

BastionAmiId?=ami-09ab237af4a23d09e
CodaAmiId?=ami-04b9e92b5572fa0d1


bucket?=init-stack-templatebucket-h0zgfseupync
role=arn:aws:iam::$(account_id):role/cloudformation-role

## Condtionnal start of the stacks
RunVpcStack?=true
RunBastionStack?=true
RunCodaStack?=true
RunCodaWorkerStack?=true
## Variables
CodaInstanceType?=c5.2xlarge
CodaWorkerInstanceType?=c5.2xlarge

## Create service linked for Elasticsearch
#service-linked:
#	aws --profile $(profile) \
#		iam create-service-linked-role \
#		--aws-service-name es.amazonaws.com || echo "Service Linked already UP"

## Update aws-cli
cphp-update-aws-cli: install-pip
	pip install "awscli<=1.16.142" --upgrade --user

## Package Cloud Formation template
package:
	  aws --profile $(profile) \
		--region $(region) \
	  cloudformation package \
		--template-file cloudformation/stacks/main.yml \
		--s3-bucket $(bucket) \
		--output-template-file template-output.yml

## Deploy Cloud Formation stack
deploy: package
	aws --profile $(profile) \
		--region $(region) \
	  cloudformation deploy \
		--template-file template-output.yml \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--role-arn $(role) \
		--stack-name $(stack_name) \
		--parameter-overrides  \
			BastionAmiId=$(BastionAmiId) CodaAmiId=$(CodaAmiId) CodaWorkerAmiId=$(CodaAmiId)\
        	KeyName=$(KeyName) \
        	CodaInstanceType=$(CodaInstanceType) \
        	CodaWorkerInstanceType=$(CodaWorkerInstanceType) \
        	RunVpcStack=$(RunVpcStack) \
        	RunBastionStack=$(RunBastionStack) \
			BucketInfra=$(bucket)

## Describe Cloud Formation stack outputs
describe:
	aws --profile $(profile) \
		--region $(region) \
	  cloudformation describe-stacks \
		--stack-name $(stack_name) \
		--query 'Stacks[0].Outputs[*].[OutputKey, OutputValue]' --output text

## Delete Cloud Formation stack
#delete:
#	aws --profile $(profile) \
#		--region $(region) \
#	  cloudformation delete-stack \
#		--stack-name $(stack_name)
