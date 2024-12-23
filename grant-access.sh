#!/usr/bin/env bash
# Grant AWS ReadOnly access to Byondlabs
set -e

AWS_USER=$(aws sts get-caller-identity --output text --query 'Arn' | tr -d '\r')
AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account' | tr -d '\r')

echo "Running as AWS user: ${AWS_USER}"
echo "For AWS account: ${AWS_ACCOUNT}"
echo
echo "Press enter to continue..."
read -r
echo "Creating custom role \`ByondLabsRole\`: "

aws iam create-role \
	--role-name ByondLabsRole \
	--assume-role-policy-document file://assume-role-trust-policy.json

aws iam attach-role-policy \
	--role-name ByondLabsRole \
	--policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

aws iam attach-role-policy \
	--role-name ByondLabsRole \
	--policy-arn arn:aws:iam::aws:policy/job-function/Billing

aws iam attach-role-policy \
	--role-name ByondLabsRole \
	--policy-arn arn:aws:iam::aws:policy/AWSSavingsPlansReadOnlyAccess

echo "Creating byondlabs custom policies: "
aws iam create-policy \
	--policy-name ByondLabsBillingPolicy \
	--policy-document file://billing-policy.json
echo "Created \`ByondLabsBillingPolicy\` policy"

aws iam create-policy \
	--policy-name ByondLabsReadOnlyPolicy \
	--policy-document file://readonly-policy.json

echo "Attaching policies to the role"
aws iam attach-role-policy \
	--role-name ByondLabsRole \
	--policy-arn "arn:aws:iam::${AWS_ACCOUNT}:policy/ByondLabsBillingPolicy"

aws iam attach-role-policy \
	--role-name ByondLabsRole \
	--policy-arn "arn:aws:iam::${AWS_ACCOUNT}:policy/ByondLabsReadOnlyPolicy"

echo "Role created successfully!"
