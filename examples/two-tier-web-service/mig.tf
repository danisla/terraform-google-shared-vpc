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

data "template_file" "startup-script-tier1" {
  template = "${file("${format("%s/nginx_upstream.sh.tpl", path.module)}")}"

  vars {
    UPSTREAM = "${module.service-tier2-ilb.ip_address}"
  }
}

data "template_file" "startup-script-tier2" {
  template = "${file("${format("%s/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = ""
  }
}

data "google_compute_subnetwork" "shared-service" {
  name    = "default"
  region  = "${var.region}"
  project = "${module.shared-vpc.project_id}"
}

module "service-tier1" {
  source             = "GoogleCloudPlatform/managed-instance-group/google"
  version            = "1.1.13"
  name               = "service-tier1"
  project            = "${google_project_services.tier1.project}"
  network            = "${data.google_compute_subnetwork.shared-service.network}"
  subnetwork         = "${data.google_compute_subnetwork.shared-service.name}"
  subnetwork_project = "${module.shared-vpc.project_id}"
  target_pools       = ["${module.service-tier1-lb.target_pool}"]
  zonal              = false
  autoscaling        = true
  min_replicas       = 3
  max_replicas       = 10

  autoscaling_cpu = [{
    target = 0.8
  }]

  target_tags       = ["service-tier1"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.startup-script-tier1.rendered}"
  depends_id        = "${module.shared-vpc.shared_vpc_projects[0]}"
}

module "service-tier2" {
  source             = "GoogleCloudPlatform/managed-instance-group/google"
  name               = "service-tier2"
  project            = "${google_project_services.tier2.project}"
  network            = "${data.google_compute_subnetwork.shared-service.network}"
  subnetwork         = "${data.google_compute_subnetwork.shared-service.name}"
  subnetwork_project = "${module.shared-vpc.project_id}"
  zonal              = false
  autoscaling        = true
  min_replicas       = 3
  max_replicas       = 10

  autoscaling_cpu = [{
    target = 0.8
  }]

  target_tags       = ["service-tier2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.startup-script-tier2.rendered}"
  depends_id        = "${module.shared-vpc.shared_vpc_projects[1]}"
}
