/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "org_id" {}
variable "billing_account" {}

variable "region" {
  default = "us-central1"
}

provider "google" {
  region = "${var.region}"
}

module "shared-vpc" {
  source               = "../../"
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

/* Service Tier 1 Project */
resource "random_id" "tier1-project" {
  byte_length = 2
  prefix      = "service-tier1-"
}

resource "google_project" "tier1" {
  name            = "Service Tier1"
  org_id          = "${var.org_id}"
  project_id      = "${random_id.tier1-project.hex}"
  billing_account = "${var.billing_account}"
}

resource "google_project_services" "tier1" {
  project = "${google_project.tier1.project_id}"

  services = [
    "compute.googleapis.com",
  ]
}

/* Service Tier 2 Project */
resource "random_id" "tier2-project" {
  byte_length = 2
  prefix      = "service-tier2-"
}

resource "google_project" "tier2" {
  name            = "Service Tier2"
  org_id          = "${var.org_id}"
  project_id      = "${random_id.tier2-project.hex}"
  billing_account = "${var.billing_account}"
}

resource "google_project_services" "tier2" {
  project = "${google_project.tier2.project_id}"

  services = [
    "compute.googleapis.com",
  ]
}
