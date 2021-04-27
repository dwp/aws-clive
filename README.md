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
