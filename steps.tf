resource "aws_s3_bucket_object" "create_databases_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws-clive/create-databases.sh"
  content = templatefile("${path.module}/steps/create-databases.sh",
    {
      clive_db                = local.clive_db
      hive_metastore_location = local.hive_metastore_location
      published_bucket        = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
    }
  )
}

resource "aws_s3_bucket_object" "run_clive" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws-clive/run-clive.sh"
  content = templatefile("${path.module}/steps/run-clive.sh",
    {
      target_db = local.clive_db
      serde     = local.serde
      data_path = local.data_path
    }
  )
}

