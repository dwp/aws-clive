variable "emr_release" {
  default = {
    development = "6.2.0"
    qa          = "6.2.0"
    integration = "6.2.0"
    preprod     = "6.2.0"
    production  = "6.2.0"
  }
}

variable "hive_tez_container_size" {}

variable "hive_tez_java_opts" {}

variable "tez_grouping_min_size" {}

variable "tez_grouping_max_size" {}

variable "tez_am_resource_memory_mb" {}

variable "tez_am_launch_cmd_opts" {}
