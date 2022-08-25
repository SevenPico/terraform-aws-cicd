module "artifacts_bucket" {
  source     = "cloudposse/s3-bucket/aws"
  version    = "2.0.3"
  context    = module.context.self
  attributes = ["artifacts"]

  acl                           = "private"
  allow_encrypted_uploads_only  = false
  allow_ssl_requests_only       = false
  allowed_bucket_actions        = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  block_public_acls             = true
  block_public_policy           = true
  bucket_key_enabled            = false
  bucket_name                   = null
  cors_rule_inputs              = null
  force_destroy                 = false
  grants                        = []
  ignore_public_acls            = true
  kms_master_key_arn            = ""
  lifecycle_configuration_rules = []
  lifecycle_rule_ids            = []
  lifecycle_rules               = null
  logging                       = null
  object_lock_configuration     = null
  policy                        = ""
  privileged_principal_actions  = []
  privileged_principal_arns     = []
  replication_rules             = null
  restrict_public_buckets       = true
  s3_object_ownership           = "ObjectWriter"
  s3_replica_bucket_arn         = ""
  s3_replication_enabled        = false
  s3_replication_rules          = null
  s3_replication_source_roles   = []
  source_policy_documents       = []
  sse_algorithm                 = "AES256"
  transfer_acceleration_enabled = false
  user_enabled                  = false
  versioning_enabled            = true
  website_inputs                = null
}

module "website" {
  source  = "../../../terraform-aws-s3-website"
  context = module.this.site

  acm_certificate_arn                     = ""
  deployment_principal_arns               = []
  dns_alias_enabled                       = false
  parent_zone_id                          = ""
  parent_zone_name                        = ""
}


# name     = action.key
# category = action.value.category
# owner    = action.value.owner
# provider = action.value.provider
# version  = action.value.version

# configuration    = try(action.value.configuration, null)
# input_artifacts  = try(action.value.input_artifacts, null)
# output_artifacts = try(action.value.output_artifacts, null)
# role_arn         = try(action.value.role_arn, null)
# run_order        = try(action.value.run_order, null)
# region           = try(action.value.region, null)
# namespace        = try(action.value.namespace, null)

# category         - (Required) A category defines what kind of action can be taken in the stage, and constrains the provider type for the action. Possible values are Approval, Build, Deploy, Invoke, Source and Test.
# owner            - (Required) The creator of the action being called. Possible values are AWS, Custom and ThirdParty.
# name             - (Required) The action declaration's name.
# provider         - (Required) The provider of the service being called by the action. Valid providers are determined by the action category. Provider names are listed in the Action Structure Reference documentation.
# version          - (Required) A string that identifies the action type.

# configuration    - (Optional) A map of the action declaration's configuration. Configurations options for action types and providers can be found in the Pipeline Structure Reference and Action Structure Reference documentation.
# input_artifacts  - (Optional) A list of artifact names to be worked on.
# output_artifacts - (Optional) A list of artifact names to output. Output artifact names must be unique within a pipeline.
# role_arn         - (Optional) The ARN of the IAM service role that will perform the declared action. This is assumed through the roleArn for the pipeline.
# run_order        - (Optional) The order in which actions are run.
# region           - (Optional) The region in which to run the action.
# namespace        - (Optional) The namespace all output variables will be accessed from.


module "s3_website_pipeline" {
  source  = "../../codepipeline"
  context = module.context.self

  artifact_stores = {
    artifacts = {
      location = module.artifacts_bucket.id
    }
  }

  stages = {
    source = {
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      output_artifacts = ["source"]
      input_artifacts  = null
      run_order        = 1
      role_arn         = null
      region           = null

      configuration = {
        S3Bucket             = module.artifacts_bucket.id
        S3ObjectKey          = "${module.context.id}-${var.version}.zip"
        PollForSourceChanges = true
      }
    }

    # pre-deploy = {
    #   category = "Build"
    #   owner    = "AWS"
    #   provider = "CodeBuild"
    #   version  = "1"

    #   configuration = {
    #     ProjectName = module.context.id
    #     PrimarySource
    #   }
    # }

    # deploy = {
    #   category = "Source"
    #   owner    = "AWS"
    #   provider = "S3"
    #   version  = "1"

    #   configuration = {
    #     BucketName = "FIXME"
    #     ObjectKey  = "FIXME"
    #     Extract    = true
    #   }
    # }
  }
}
# module "artifacts_bucket" {
#   source     = "cloudposse/s3-bucket/aws"
#   version    = "2.0.3"
#   context    = module.context.self
#   attributes = ["artifacts"]

#   acl                           = "private"
#   allow_encrypted_uploads_only  = false
#   allow_ssl_requests_only       = false
#   allowed_bucket_actions        = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
#   block_public_acls             = true
#   block_public_policy           = true
#   bucket_key_enabled            = false
#   bucket_name                   = null
#   cors_rule_inputs              = null
#   force_destroy                 = false
#   grants                        = []
#   ignore_public_acls            = true
#   kms_master_key_arn            = ""
#   lifecycle_configuration_rules = []
#   lifecycle_rule_ids            = []
#   lifecycle_rules               = null
#   logging                       = null
#   object_lock_configuration     = null
#   policy                        = ""
#   privileged_principal_actions  = []
#   privileged_principal_arns     = []
#   replication_rules             = null
#   restrict_public_buckets       = true
#   s3_object_ownership           = "ObjectWriter"
#   s3_replica_bucket_arn         = ""
#   s3_replication_enabled        = false
#   s3_replication_rules          = null
#   s3_replication_source_roles   = []
#   source_policy_documents       = []
#   sse_algorithm                 = "AES256"
#   transfer_acceleration_enabled = false
#   user_enabled                  = false
#   versioning_enabled            = true
#   website_inputs                = null
# }

# module "website" {
#   source  = "../../../terraform-aws-s3-website"
#   context = module.this.site

#   acm_certificate_arn                     = ""
#   deployment_principal_arns               = []
#   dns_alias_enabled                       = false
#   parent_zone_id                          = ""
#   parent_zone_name                        = ""
# }


# name     = action.key
# category = action.value.category
# owner    = action.value.owner
# provider = action.value.provider
# version  = action.value.version

# configuration    = try(action.value.configuration, null)
# input_artifacts  = try(action.value.input_artifacts, null)
# output_artifacts = try(action.value.output_artifacts, null)
# role_arn         = try(action.value.role_arn, null)
# run_order        = try(action.value.run_order, null)
# region           = try(action.value.region, null)
# namespace        = try(action.value.namespace, null)

# category         - (Required) A category defines what kind of action can be taken in the stage, and constrains the provider type for the action. Possible values are Approval, Build, Deploy, Invoke, Source and Test.
# owner            - (Required) The creator of the action being called. Possible values are AWS, Custom and ThirdParty.
# name             - (Required) The action declaration's name.
# provider         - (Required) The provider of the service being called by the action. Valid providers are determined by the action category. Provider names are listed in the Action Structure Reference documentation.
# version          - (Required) A string that identifies the action type.

# configuration    - (Optional) A map of the action declaration's configuration. Configurations options for action types and providers can be found in the Pipeline Structure Reference and Action Structure Reference documentation.
# input_artifacts  - (Optional) A list of artifact names to be worked on.
# output_artifacts - (Optional) A list of artifact names to output. Output artifact names must be unique within a pipeline.
# role_arn         - (Optional) The ARN of the IAM service role that will perform the declared action. This is assumed through the roleArn for the pipeline.
# run_order        - (Optional) The order in which actions are run.
# region           - (Optional) The region in which to run the action.
# namespace        - (Optional) The namespace all output variables will be accessed from.


module "s3_website_pipeline" {
  source  = "../../codepipeline"
  context = module.context.self

  artifact_stores = {
    artifacts = {
      location = module.artifacts_bucket.id
    }
  }

  stages = {
    source = {
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      output_artifacts = ["source"]
      input_artifacts  = null
      run_order        = 1
      role_arn         = null
      region           = null

      configuration = {
        S3Bucket             = module.artifacts_bucket.id
        S3ObjectKey          = "${module.context.id}-${var.version}.zip"
        PollForSourceChanges = true
      }
    }

    pre-deploy = {
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      configuration = {
        ProjectName = module.context.id
        # PrimarySource
      }
    }

    deploy = {
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      configuration = {
        BucketName = "FIXME"
        ObjectKey  = "FIXME"
        Extract    = true
      }
    }
  }
}
