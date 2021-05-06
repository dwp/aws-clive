# aws-clive

## How the E2E tests work right now

A completed output is taken from `analytical-dataset-generation` and put into the `published_bucket` in a folder labelled `e2e-test-clive-dataset` this is done in the dev and qa environments.  
If those files are ever deleted they will need to be manually replaced. The reason we don't dynamically recreate them is that they require to have the encryption metadata attached to those files and ADG is the provider of those.  

The Clive dataset for the E2E is built on the small dataset in the above prefix and a comparison is made on one of the collections.  


Running aviator will create the pipeline required on the AWS-Concourse instance, in order pass a mandatory CI ran status check.  this will likely require you to login to Concourse, if you haven't already.

After cloning this repo, please generate `terraform.tf` and `terraform.tfvars` files:  
`make bootstrap`

In addition, you may want to do the following: 

1. Create non-default Terraform workspaces as and if required:  
    `make terraform-workspace-new workspace=<workspace_name>` e.g.  
    ```make terraform-workspace-new workspace=qa```

1. Configure Concourse CI pipeline:
    1. Add/remove jobs in `./ci/jobs` as required 
    1. Create CI pipeline:  
`aviator`

## How the Clive object tagger works

Upon the successful execution of Clive, a `clive_success` Cloudwatch Event is pushed, when this event is pushed it
triggers an event rule named `clive_success_start_object_tagger`.  
Definitions for both of these can be found within `cloudwatch_events.tf`.

The Event rule mentioned above will call the `aws_clive_emr_launcher` lambda with 2 parameters, these are provided
values on the rule definition using `local.data_classification` which can be found in `local.tf`.

### Parameters

|       Key      |                   Example                    |
|----------------|----------------------------------------------|
| data-s3-prefix | analytical-dataset/full/2021-05-06_01-44-46/ |
| csv-location   | s3://dir/sub_dir/data.csv                    |

