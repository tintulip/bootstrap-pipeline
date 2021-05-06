# bootstrap-pipeline

This repository creates the components required to set up the `website-infra` pipeline. In order to do this, it requires to be run from the laptop as an administrator and push any changes to keep the changes in sync.

## What is created
1. S3 bucket to store state for all the terraform stacks in the production account 
2. IAM user(`website-infra`)
3. Minimal role for the IAM user to assume:
    - S3 full access
    - IAM operations that include creating and deleting users,policies,groups and roles.
    - Most Cloudfront operations.

## Local to remote state
Initially the state was stored locally, the terraform code that did this was `backend "local" {}`. After the first `terraform apply` a `S3 bucket for state` was created and the state was stored locally. In order for the state bucket to be stored remotely, the `backend` type was changed to S3. The bucket name referenced was the newly created bucket. By running `terraform init`, terraform asked to push the local state to the remote `S3 backend`.


## SSO Set up

To configure profile run `aws configure sso` and choose the `production` account and from the roles pick the `AWSAdministratorAccess` role. Then a name for the profile will need to be specified, the profile name will be referenced when running `terraform` commands.

## Running terraform commands
`AWS_PROFILE=<profile name> terraform init`

`AWS_PROFILE=<profile name> terraform validate`

`AWS_PROFILE=<profile name> terraform plan`

`AWS_PROFILE=<profile name> terraform apply`

## Testing

Run [tfsec](https://github.com/tfsec/tfsec), but needs it to be installed prior (`go get -u github.com/tfsec/tfsec/cmd/tfsec`) using `tfsec .`

Run [checkov](https://github.com/bridgecrewio/checkov) but needs to be installed prior, using `checkov -d .`
