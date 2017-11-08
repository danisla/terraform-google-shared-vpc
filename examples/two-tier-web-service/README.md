# Shared VPC Two Tier Web Service Example

This example demonstrates how to separate the projects in your organization so that different teams can work independently on shared networks.

For details on the shared VPC example, see the reference architecture in the Compute Engine docs: [Two-tier web service](https://cloud.google.com/compute/docs/shared-vpc/#two-tier_web_service)

**Figure 1.** *diagram of Google Cloud resources*

![architecture diagram](https://cloud.google.com/compute/images/xpn/xpn-2-tier-setup.svg)

## Before you begin

The user running Terraform requires Organization level `Compute shared VPC Admin` permissions to work with the Shared VPC resources.

Add the `compute.xpnAdmin` role to your GCP user account:

```shell
ORG_ID=$(gcloud organizations list --format='value(name)' --limit=1)
GOOGLE_ACCOUNT=$(gcloud config get-value account)

gcloud beta organizations add-iam-policy-binding ${ORG_ID} \
    --member user:${GOOGLE_ACCOUNT} \
    --role roles/compute.xpnAdmin
```

## Set up the environment

Login with the application-default credentials for your GCP user:

```
gcloud auth application-default login
```

Locate your organization ID:

```
gcloud organizations list
```

Locate your billing account ID:

```
gcloud beta billing accounts list
```

Set the environment variables in the `terraform.tfvars` file:

```shell
echo 'org_id = "YOUR_ORG_ID"' > terraform.tfvars
echo 'billing_account = "YOUR_BILLING_ACCOUNT_ID"' >> terraform.tfvars
```

## Run Terraform

```
terraform init
terraform plan
terraform apply
```

