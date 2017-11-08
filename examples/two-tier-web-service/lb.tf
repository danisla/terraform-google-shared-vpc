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
 
variable service_ilb_ip_map {
  type = "map"

  default = {
    us-west1 {
      ip = "10.138.1.250"
    }

    us-central1 {
      ip = "10.128.1.250"
    }

    us-east1 {
      ip = "10.142.1.250"
    }

    us-east4 {
      ip = "10.150.1.250"
    }

    europe-west1 {
      ip = "10.132.1.250"
    }

    europe-west2 {
      ip = "10.154.1.250"
    }

    europe-west3 {
      ip = "10.156.1.250"
    }

    asia-southeast1 {
      ip = "10.148.1.250"
    }

    asia-east1 {
      ip = "10.142.1.250"
    }

    asia-northeast1 {
      ip = "10.146.1.250"
    }

    australia-southeast1 {
      ip = "10.152.1.250"
    }
  }
}

module "service-tier1-lb" {
  // source       = "github.com/GoogleCloudPlatform/terraform-google-lb"
  source           = "../../../terraform-google-lb"
  region           = "${var.region}"
  name             = "service-tier1-lb"
  project          = "${google_project_services.tier1.project}"
  firewall_project = "${module.shared-vpc.project_id}"
  service_port     = "${module.service-tier1.service_port}"
  target_tags      = ["${module.service-tier1.target_tags}"]
}

module "service-tier2-ilb" {
  // source      = "github.com/GoogleCloudPlatform/terraform-google-lb-internal"
  source          = "../../../terraform-google-lb-internal"
  region          = "${var.region}"
  name            = "service-tier2-ilb"
  project         = "${google_project_services.tier2.project}"
  network         = "${data.google_compute_subnetwork.shared-service.name}"
  network_project = "${data.google_compute_subnetwork.shared-service.project}"
  ports           = ["${module.service-tier2.service_port}"]
  health_port     = "${module.service-tier2.service_port}"
  source_tags     = ["${module.service-tier2.target_tags}"]
  target_tags     = ["${module.service-tier2.target_tags}"]
  ip_address      = "${lookup(var.service_ilb_ip_map["${var.region}"], "ip")}"
  ip_protocol     = "TCP"

  backends = [
    {
      group = "${module.service-tier2.region_instance_group}"
    },
  ]
}
