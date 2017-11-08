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
 
variable project_name {
  description = "Name of the host project."
  default     = "Host"
}

variable project_id {
  description = "Project ID for the host project. If not given, the default will be 'host-<random id>'."
  default     = ""
}

variable org_id {
  description = "Organization ID for the host project. Mutually exclusive from var.folder_id."
  default     = ""
}

variable billing_account {
  description = "Billing account ID for the host project, from `gcloud beta billing accounts list`"
}

variable project_services {
  description = "List of host project services to enable."
  type        = "list"

  default = [
    "compute.googleapis.com",
  ]
}

variable num_service_projects {
  description = "Number of service projects associated with the host project. Must be the same as the number of var.service_project_ids passed."
}

variable service_project_ids {
  description = "List of associated service projects to link with the host project."
  type        = "list"
  default     = []
}

variable network_users {
  description = "List of network user members for roles/compute.networkUser IAM policy. Typically this would at least include each service project's cloudservices service account in the form of: serviceAccount:PROJECT_NUMBER@cloudservices.gserviceaccount.com."
  type        = "list"
  default     = []
}
