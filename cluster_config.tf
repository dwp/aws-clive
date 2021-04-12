resource "aws_emr_security_configuration" "ebs_emrfs_em" {
  name          = "aws_emr_template_repository_ebs_emrfs"
  configuration = jsonencode(local.ebs_emrfs_em)
}

#TODO remove this
output "security_configuration" {
  value = aws_emr_security_configuration.ebs_emrfs_em
}

resource "aws_s3_bucket_object" "cluster" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_emr_template_repository/cluster.yaml"
  content = templatefile("${path.module}/cluster_config/cluster.yaml.tpl",
    {
      s3_log_bucket          = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix          = local.s3_log_prefix
      ami_id                 = var.emr_ami_id
      service_role           = aws_iam_role.aws_emr_template_repository_emr_service.arn
      instance_profile       = aws_iam_instance_profile.aws_emr_template_repository.arn
      security_configuration = aws_emr_security_configuration.ebs_emrfs_em.id
      emr_release            = var.emr_release[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "instances" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_emr_template_repository/instances.yaml"
  content = templatefile("${path.module}/cluster_config/instances.yaml.tpl",
    {
      keep_cluster_alive              = local.keep_cluster_alive[local.environment]
      add_master_sg                   = aws_security_group.aws_emr_template_repository_common.id
      add_slave_sg                    = aws_security_group.aws_emr_template_repository_common.id
      subnet_id                       = local.emr_subnet_id[local.environment]
      master_sg                       = aws_security_group.aws_emr_template_repository_master.id
      slave_sg                        = aws_security_group.aws_emr_template_repository_slave.id
      service_access_sg               = aws_security_group.aws_emr_template_repository_emr_service.id
      instance_type_core_one          = var.emr_instance_type_core_one[local.environment]
      instance_type_master            = var.emr_instance_type_master[local.environment]
      core_instance_count             = var.emr_core_instance_count[local.environment]
      capacity_reservation_preference = local.emr_capacity_reservation_preference[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "steps" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_emr_template_repository/steps.yaml"
  content = templatefile("${path.module}/cluster_config/steps.yaml.tpl",
    {
      s3_config_bucket    = data.terraform_remote_state.common.outputs.config_bucket.id
      action_on_failure   = local.step_fail_action[local.environment]
      s3_published_bucket = data.terraform_remote_state.common.outputs.published_bucket.id
    }
  )
}


resource "aws_s3_bucket_object" "configurations" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_emr_template_repository/configurations.yaml"
  content = templatefile("${path.module}/cluster_config/configurations.yaml.tpl",
    {
      s3_log_bucket                                 = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix                                 = local.s3_log_prefix
      proxy_no_proxy                                = replace(replace(local.no_proxy, ",", "|"), ".s3", "*.s3")
      proxy_http_host                               = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_http_port                               = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      proxy_https_host                              = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_https_port                              = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      environment                                   = local.environment
      hive_tez_container_size                       = local.hive_tez_container_size[local.environment]
      hive_tez_java_opts                            = local.hive_tez_java_opts[local.environment]
      hive_auto_convert_join_noconditionaltask_size = local.hive_auto_convert_join_noconditionaltask_size[local.environment]
      tez_grouping_min_size                         = local.tez_grouping_min_size[local.environment]
      tez_grouping_max_size                         = local.tez_grouping_max_size[local.environment]
      tez_am_resource_memory_mb                     = local.tez_am_resource_memory_mb[local.environment]
      tez_am_launch_cmd_opts                        = local.tez_am_launch_cmd_opts[local.environment]
      tez_runtime_io_sort_mb                        = local.tez_runtime_io_sort_mb[local.environment]
      tez_runtime_unordered_output_buffer_size_mb   = local.tez_runtime_unordered_output_buffer_size_mb[local.environment]
    }
  )
}

