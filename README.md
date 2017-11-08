# Shared VPC module

Terraform module for creating a shared VPC host network project and service project associations. See the [Google Cloud Platform documentation](https://cloud.google.com/compute/docs/shared-vpc/) for details.

## Usage

```ruby
module "shared-vpc" {
  source               = "github.com/danisla/terraform-google-shared-vpc"
  project_name         = "Host"
  org_id               = "${var.org_id}"
  billing_account      = "${var.billing_account}"
  num_service_projects = 2

  service_project_ids = [
    "${google_project_services.tier1.project}",
    "${google_project_services.tier2.project}",
  ]

  network_users = [
    "serviceAccount:${google_project.tier1.number}@cloudservices.gserviceaccount.com",
    "serviceAccount:${google_project.tier2.number}@cloudservices.gserviceaccount.com",
  ]
}
```
## Requirements

The Google Cloud credentials used by terraform must have organization level `Compute shared VPC Admin` permissions to enable Shared VPC.

```shell
TF_VAR_org_id=$(gcloud organizations list --format='value(name)' --limit=1)
GOOGLE_ACCOUNT=$(gcloud config get-value account)

gcloud beta organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member user:${GOOGLE_ACCOUNT} \
  --role roles/compute.xpnAdmin
```

## Module Best Practices

- When referencing projects, use the `google_project_services.name.project` reference to ensure APIs are enabled before they are used.
- To ensure the service projects are associated with the shared VPC before instances use it, add the output variable `shared_vpc_projects[n]` to the instance metadata to create the dependency. The `terraform-google-managed-instance-group` module does this by providing the `depends_id` input variable.

See the [`two-tier-web-service`](./examples/two-tier-web-service/) example for details.

## Resources created

- [`google_project.host`](https://www.terraform.io/docs/providers/google/r/google_project.html): Project containing the host network.
- [`google_project_services.host`](https://www.terraform.io/docs/providers/google/r/google_project_services.html): APIs enabled for the host project.
- [`google_project_iam_policy.network-users`](https://www.terraform.io/docs/providers/google/r/google_project_iam_policy.html): IAM policy to allow users from service projects permission to use the host networks.
- [`google_compute_shared_vpc_host_project.host`](https://www.terraform.io/docs/providers/google/r/compute_shared_vpc_host_project.html): Shared VPC resource on the host project.
- [`google_compute_shared_vpc_service_project.service.*`](https://www.terraform.io/docs/providers/google/r/compute_shared_vpc_service_project.html): Shared VPC association for service projecst to the host project.