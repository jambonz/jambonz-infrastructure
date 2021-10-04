#!/bin/bash

TIMEOUT=20
PAUSE=5

aws_get_instance_id() {
	instance_id=$( (curl http://169.254.169.254/latest/meta-data/instance-id) )
	if [ -n "$instance_id" ];	then return 0; else return 1; fi
}

aws_get_instance_region() {
	instance_region=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
	# region here needs the last character removed to work
	instance_region=${instance_region::-1}
	if [ -n "$instance_region" ];	then return 0; else return 1; fi
}

aws_get_instance_environment() {
	instance_environment=$(aws ec2 describe-tags --region $instance_region --filters "Name=resource-id,Values=$1" "Name=key,Values=Environment" --query "Tags[*].Value" --output text)
	if [ -n "$instance_environment" ]; then return 0; else return 1; fi
}

aws_get_unassigned_eips() {
	local describe_addreses_response=$(aws ec2 describe-addresses --region $instance_region --filters "Name=tag:Environment,Values=$instance_environment" --query "Addresses[?AssociationId==null].AllocationId" --output text)
	eips=(${describe_addreses_response///})
	if [ -n "$describe_addreses_response" ]; then return 0; else return 1; fi
}

aws_get_details() {
	if aws_get_instance_id;	then
		echo "Instance ID: ${instance_id}."
		if aws_get_instance_region;	then
			echo "Instance Region: ${instance_region}."
			if aws_get_instance_environment $instance_id;	then
				echo "Instance Environment: ${instance_environment}."
			else
				echo "Failed to get Instance Environment. ${instance_environment}."
				return 1
			fi
		else
			echo "Failed to get Instance Region. ${instance_region}."
			return 1
		fi
	else
		echo "Failed to get Instance ID. ${instance_id}."
		return 1
	fi
}

attempt_to_assign_eip() {
	local result;
	local exit_code;
  	result=$( (aws ec2 associate-address --region $instance_region --instance-id $instance_id --allocation-id $1 --no-allow-reassociation) 2>&1 )
	exit_code=$?
	if [ "$exit_code" -ne 0 ]; then
		echo "Failed to assign Elastic IP [$1] to Instance [$instance_id]. ERROR: $result"
	fi
  return $exit_code
}

try_to_assign() {
	local last_result;
	for eip_id in "${eips[@]}"; do
		echo "Attempting to assign Elastic IP to instance..."
		if attempt_to_assign_eip $eip_id;  then
			echo "Elastic IP successfully assigned to instance."
			return 0
		fi
	done
	return 1
}

main() {
	echo "Assigning Elastic IP..."
	local end_time=$((SECONDS+TIMEOUT))
	echo "Timeout: ${end_time}"

	if ! aws_get_details; then
		exit 1
	fi

	while [ $SECONDS -lt $end_time ]; do
		if aws_get_unassigned_eips && try_to_assign ${eips}; then
			echo "Successfully assigned EIP."
			exit 0
		fi
		echo "Failed to assign EIP. Pausing for $PAUSE seconds before retrying..."
		sleep $PAUSE
	done

	echo "Failed to assign Elastic IP after $TIMEOUT seconds. Exiting."
	exit 1
}

declare instance_id
declare instance_region
declare instance_environment
declare eips

main "$@"