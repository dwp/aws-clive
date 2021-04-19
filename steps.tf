#uploading of step files to s3 go here


resource "aws_s3_bucket_object" "create_databases_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws-clive/create-databases.sh"
  content = templatefile("${path.module}/steps/create-databases.sh",
    {
      clive_db = local.clive_db
    }
  )
}
