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
 
resource "random_id" "default-project-id" {
  byte_length = 2
  prefix      = "host-"
}

resource "google_project" "host" {
  name            = "${var.project_name}"
  org_id          = "${var.org_id}"
  project_id      = "${var.project_id == "" ? random_id.default-project-id.hex : var.project_id}"
  billing_account = "${var.billing_account}"
}

resource "google_project_services" "host" {
  project  = "${google_project.host.project_id}"
  services = ["${var.project_services}"]
}

data "google_iam_policy" "network-users" {
  binding {
    role    = "roles/compute.networkUser"
    members = ["${var.network_users}"]
  }
}

resource "google_project_iam_policy" "network-users" {
  count       = "${length(var.num_service_projects) == 0 ? 0 : 1}"
  project     = "${google_project_services.host.project}"
  policy_data = "${data.google_iam_policy.network-users.policy_data}"
}

resource "google_compute_shared_vpc_host_project" "host" {
  project = "${google_project_services.host.project}"

  depends_on = ["google_project_services.host"]
}

resource "google_compute_shared_vpc_service_project" "service" {
  count           = "${var.num_service_projects}"
  host_project    = "${google_project_services.host.project}"
  service_project = "${element(var.service_project_ids, count.index)}"

  // The host project must enable shared VPC first
  depends_on = ["google_compute_shared_vpc_host_project.host"]
}
