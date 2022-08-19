
resource "aws_codebuild_project" "this" {
  count          = module.this.enabled ? 1 : 0
  name           = local.codebuild_name
  description    = "Allows for changes to files upon deployment to the CDN"
  build_timeout  = "5"
  queued_timeout = "5"
  service_role   = var.codepipeline_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_REGION"
      value = join("", data.aws_region.current[*].name)
    }
    environment_variable {
      name  = "S3_TARGET_BUCKET"
      value = "s3://${module.site.s3_bucket}"
    }

    environment_variable {
      name  = "AWS_SECRETS_REGION"
      value = join("", data.aws_region.current[*].name)
    }
    environment_variable {
      name  = "S3_SECRETS_BUCKET"
      value = "s3://${var.config_bucket_name}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "deployspec.yml"
  }

  tags = module.this.context.tags
}



# The following arguments are required:

# artifacts - (Required) Configuration block. Detailed below.
# environment - (Required) Configuration block. Detailed below.
# name - (Required) Project's name.
# service_role - (Required) Amazon Resource Name (ARN) of the AWS Identity and Access Management (IAM) role that enables AWS CodeBuild to interact with dependent AWS services on behalf of the AWS account.
# source - (Required) Configuration block. Detailed below.
# The following arguments are optional:

# badge_enabled - (Optional) Generates a publicly-accessible URL for the projects build badge. Available as badge_url attribute when enabled.
# build_batch_config - (Optional) Defines the batch build options for the project.
# build_timeout - (Optional) Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. The default is 60 minutes.
# cache - (Optional) Configuration block. Detailed below.
# concurrent_build_limit - (Optional) Specify a maximum number of concurrent builds for the project. The value specified must be greater than 0 and less than the account concurrent running builds limit.
# description - (Optional) Short description of the project.
# file_system_locations - (Optional) A set of file system locations to to mount inside the build. File system locations are documented below.
# encryption_key - (Optional) AWS Key Management Service (AWS KMS) customer master key (CMK) to be used for encrypting the build project's build output artifacts.
# logs_config - (Optional) Configuration block. Detailed below.
# project_visibility - (Optional) Specifies the visibility of the project's builds. Possible values are: PUBLIC_READ and PRIVATE. Default value is PRIVATE.
# resource_access_role - The ARN of the IAM role that enables CodeBuild to access the CloudWatch Logs and Amazon S3 artifacts for the project's builds.
# queued_timeout - (Optional) Number of minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out. The default is 8 hours.
# secondary_artifacts - (Optional) Configuration block. Detailed below.
# secondary_sources - (Optional) Configuration block. Detailed below.
# secondary_source_version - (Optional) Configuration block. Detailed below.
# source_version - (Optional) Version of the build input to be built for this project. If not specified, the latest version is used.
# tags - (Optional) Map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level.
# vpc_config - (Optional) Configuration block. Detailed below.
# artifacts
# artifact_identifier - (Optional) Artifact identifier. Must be the same specified inside the AWS CodeBuild build specification.
# bucket_owner_access - (Optional) Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket. By default, only the account that uploads the objects to the bucket has access to these objects. This property allows you to give the bucket owner access to these objects. Valid values are NONE, READ_ONLY, and FULL. your CodeBuild service role must have the s3:PutBucketAcl permission. This permission allows CodeBuild to modify the access control list for the bucket.
# encryption_disabled - (Optional) Whether to disable encrypting output artifacts. If type is set to NO_ARTIFACTS, this value is ignored. Defaults to false.
# location - (Optional) Information about the build output artifact location. If type is set to CODEPIPELINE or NO_ARTIFACTS, this value is ignored. If type is set to S3, this is the name of the output bucket.
# name - (Optional) Name of the project. If type is set to S3, this is the name of the output artifact object
# namespace_type - (Optional) Namespace to use in storing build artifacts. If type is set to S3, then valid values are BUILD_ID, NONE.
# override_artifact_name (Optional) Whether a name specified in the build specification overrides the artifact name.
# packaging - (Optional) Type of build output artifact to create. If type is set to S3, valid values are NONE, ZIP
# path - (Optional) If type is set to S3, this is the path to the output artifact.
# type - (Required) Build output artifact's type. Valid values: CODEPIPELINE, NO_ARTIFACTS, S3.
# build_batch_config
# combine_artifacts - (Optional) Specifies if the build artifacts for the batch build should be combined into a single artifact location.
# restrictions - (Optional) Specifies the restrictions for the batch build.
# service_role - (Required) Specifies the service role ARN for the batch build project.
# timeout_in_mins - (Optional) Specifies the maximum amount of time, in minutes, that the batch build must be completed in.
# restrictions
# compute_types_allowed - (Optional) An array of strings that specify the compute types that are allowed for the batch build. See Build environment compute types in the AWS CodeBuild User Guide for these values.
# maximum_builds_allowed - (Optional) Specifies the maximum number of builds allowed.
# cache
# location - (Required when cache type is S3) Location where the AWS CodeBuild project stores cached resources. For type S3, the value must be a valid S3 bucket name/prefix.
# modes - (Required when cache type is LOCAL) Specifies settings that AWS CodeBuild uses to store and reuse build dependencies. Valid values: LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE.
# type - (Optional) Type of storage that will be used for the AWS CodeBuild project cache. Valid values: NO_CACHE, LOCAL, S3. Defaults to NO_CACHE.
# environment
# certificate - (Optional) ARN of the S3 bucket, path prefix and object key that contains the PEM-encoded certificate.
# compute_type - (Required) Information about the compute resources the build project will use. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE. BUILD_GENERAL1_SMALL is only valid if type is set to LINUX_CONTAINER. When type is set to LINUX_GPU_CONTAINER, compute_type must be BUILD_GENERAL1_LARGE.
# environment_variable - (Optional) Configuration block. Detailed below.
# image_pull_credentials_type - (Optional) Type of credentials AWS CodeBuild uses to pull images in your build. Valid values: CODEBUILD, SERVICE_ROLE. When you use a cross-account or private registry image, you must use SERVICE_ROLE credentials. When you use an AWS CodeBuild curated image, you must use CodeBuild credentials. Defaults to CODEBUILD.
# image - (Required) Docker image to use for this build project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest).
# privileged_mode - (Optional) Whether to enable running the Docker daemon inside a Docker container. Defaults to false.
# registry_credential - (Optional) Configuration block. Detailed below.
# type - (Required) Type of build environment to use for related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. For additional information, see the CodeBuild User Guide.
# environment: environment_variable
# name - (Required) Environment variable's name or key.
# type - (Optional) Type of environment variable. Valid values: PARAMETER_STORE, PLAINTEXT, SECRETS_MANAGER.
# value - (Required) Environment variable's value.
# environment: registry_credential
# Credentials for access to a private Docker registry.

# credential - (Required) ARN or name of credentials created using AWS Secrets Manager.
# credential_provider - (Required) Service that created the credentials to access a private Docker registry. Valid value: SECRETS_MANAGER (AWS Secrets Manager).
# logs_config
# cloudwatch_logs - (Optional) Configuration block. Detailed below.
# s3_logs - (Optional) Configuration block. Detailed below.
# logs_config: cloudwatch_logs
# group_name - (Optional) Group name of the logs in CloudWatch Logs.
# status - (Optional) Current status of logs in CloudWatch Logs for a build project. Valid values: ENABLED, DISABLED. Defaults to ENABLED.
# stream_name - (Optional) Stream name of the logs in CloudWatch Logs.
# logs_config: s3_logs
# encryption_disabled - (Optional) Whether to disable encrypting S3 logs. Defaults to false.
# location - (Optional) Name of the S3 bucket and the path prefix for S3 logs. Must be set if status is ENABLED, otherwise it must be empty.
# status - (Optional) Current status of logs in S3 for a build project. Valid values: ENABLED, DISABLED. Defaults to DISABLED.
# bucket_owner_access - (Optional) Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket. By default, only the account that uploads the objects to the bucket has access to these objects. This property allows you to give the bucket owner access to these objects. Valid values are NONE, READ_ONLY, and FULL. your CodeBuild service role must have the s3:PutBucketAcl permission. This permission allows CodeBuild to modify the access control list for the bucket.
# secondary_artifacts
# artifact_identifier - (Required) Artifact identifier. Must be the same specified inside the AWS CodeBuild build specification.
# bucket_owner_access - (Optional) Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket. By default, only the account that uploads the objects to the bucket has access to these objects. This property allows you to give the bucket owner access to these objects. Valid values are NONE, READ_ONLY, and FULL. your CodeBuild service role must have the s3:PutBucketAcl permission. This permission allows CodeBuild to modify the access control list for the bucket.
# encryption_disabled - (Optional) Whether to disable encrypting output artifacts. If type is set to NO_ARTIFACTS, this value is ignored. Defaults to false.
# location - (Optional) Information about the build output artifact location. If type is set to CODEPIPELINE or NO_ARTIFACTS, this value is ignored. If type is set to S3, this is the name of the output bucket. If path is not also specified, then location can also specify the path of the output artifact in the output bucket.
# name - (Optional) Name of the project. If type is set to S3, this is the name of the output artifact object
# namespace_type - (Optional) Namespace to use in storing build artifacts. If type is set to S3, then valid values are BUILD_ID or NONE.
# override_artifact_name (Optional) Whether a name specified in the build specification overrides the artifact name.
# packaging - (Optional) Type of build output artifact to create. If type is set to S3, valid values are NONE, ZIP
# path - (Optional) If type is set to S3, this is the path to the output artifact.
# type - (Required) Build output artifact's type. The only valid value is S3.
# secondary_sources
# auth - (Optional, Deprecated) Configuration block with the authorization settings for AWS CodeBuild to access the source code to be built. This information is for the AWS CodeBuild console's use only. Use the aws_codebuild_source_credential resource instead. Auth blocks are documented below.
# buildspec - (Optional) The build spec declaration to use for this build project's related builds. This must be set when type is NO_SOURCE. It can either be a path to a file residing in the repository to be built or a local file path leveraging the file() built-in.
# git_clone_depth - (Optional) Truncate git history to this many commits. Use 0 for a Full checkout which you need to run commands like git branch --show-current. See AWS CodePipeline User Guide: Tutorial: Use full clone with a GitHub pipeline source for details.
# git_submodules_config - (Optional) Configuration block. Detailed below.
# insecure_ssl - (Optional) Ignore SSL warnings when connecting to source control.
# location - (Optional) Location of the source code from git or s3.
# report_build_status - (Optional) Whether to report the status of a build's start and finish to your source provider. This option is only valid when your source provider is GITHUB, BITBUCKET, or GITHUB_ENTERPRISE.
# build_status_config - (Optional) Contains information that defines how the build project reports the build status to the source provider. This option is only used when the source provider is GITHUB, GITHUB_ENTERPRISE, or BITBUCKET.
# source_identifier - (Required) An identifier for this project source. The identifier can only contain alphanumeric characters and underscores, and must be less than 128 characters in length.
# type - (Required) Type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET or S3.
# secondary_sources: auth
# resource - (Optional, Deprecated) Resource value that applies to the specified authorization type. Use the aws_codebuild_source_credential resource instead.
# type - (Required, Deprecated) Authorization type to use. The only valid value is OAUTH. This data type is deprecated and is no longer accurate or used. Use the aws_codebuild_source_credential resource instead.
# secondary_sources: git_submodules_config
# This block is only valid when the type is CODECOMMIT, GITHUB or GITHUB_ENTERPRISE.

# fetch_submodules - (Required) Whether to fetch Git submodules for the AWS CodeBuild build project.
# secondary_sources: build_status_config
# context - (Optional) Specifies the context of the build status CodeBuild sends to the source provider. The usage of this parameter depends on the source provider.
# target_url - (Optional) Specifies the target url of the build status CodeBuild sends to the source provider. The usage of this parameter depends on the source provider.
# secondary_source_version
# source_identifier - (Required) An identifier for a source in the build project.
# source_version - (Required) The source version for the corresponding source identifier. See AWS docs for more details.
# source
# auth - (Optional, Deprecated) Configuration block with the authorization settings for AWS CodeBuild to access the source code to be built. This information is for the AWS CodeBuild console's use only. Use the aws_codebuild_source_credential resource instead. Auth blocks are documented below.
# buildspec - (Optional) Build specification to use for this build project's related builds. This must be set when type is NO_SOURCE.
# git_clone_depth - (Optional) Truncate git history to this many commits. Use 0 for a Full checkout which you need to run commands like git branch --show-current. See AWS CodePipeline User Guide: Tutorial: Use full clone with a GitHub pipeline source for details.
# git_submodules_config - (Optional) Configuration block. Detailed below.
# insecure_ssl - (Optional) Ignore SSL warnings when connecting to source control.
# location - (Optional) Location of the source code from git or s3.
# report_build_status - (Optional) Whether to report the status of a build's start and finish to your source provider. This option is only valid when the type is BITBUCKET or GITHUB.
# type - (Required) Type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE.
# file_system_locations supports the following:

# See ProjectFileSystemLocation for more details of the fields.

# identifier - (Optional) The name used to access a file system created by Amazon EFS. CodeBuild creates an environment variable by appending the identifier in all capital letters to CODEBUILD_. For example, if you specify my-efs for identifier, a new environment variable is create named CODEBUILD_MY-EFS.
# location - (Optional) A string that specifies the location of the file system created by Amazon EFS. Its format is efs-dns-name:/directory-path.
# mount_options - (Optional) The mount options for a file system created by AWS EFS.
# mount_point - (Optional) The location in the container where you mount the file system.
# type - (Optional) The type of the file system. The one supported type is EFS.
# source: auth
# resource - (Optional, Deprecated) Resource value that applies to the specified authorization type. Use the aws_codebuild_source_credential resource instead.
# type - (Required, Deprecated) Authorization type to use. The only valid value is OAUTH. This data type is deprecated and is no longer accurate or used. Use the aws_codebuild_source_credential resource instead.
# source: git_submodules_config
# This block is only valid when the type is CODECOMMIT, GITHUB or GITHUB_ENTERPRISE.

# fetch_submodules - (Required) Whether to fetch Git submodules for the AWS CodeBuild build project.
# vpc_config
# security_group_ids - (Required) Security group IDs to assign to running builds.
# subnets - (Required) Subnet IDs within which to run builds.
# vpc_id - (Required) ID of the VPC within which to run builds.


# TODO
# aws_codebuild_report_group
# aws_codebuild_resource_policy
# aws_codebuild_source_credential
# aws_codebuild_webhook




























resource "aws_codepipeline" "this" {
  count    = module.context.enabled ? 1 : 0
  name     = module.context.id
  role_arn = module.codepipeline_iam_role.arn

  dynamic "artifact_store" {
    for_each = var.artifact_stores
    content {
      location = artifact_store.value.location
      type     = try(artifact_store.value.type, "S3")
      region   = try(artifact_store.value.region, null)

      dynamic "encryption_key" {
        for_each = toset(can(artifact_store.value.kms_key_arn) ? [1] : [])
        content {
          id   = encryption_key.value.kms_key_arn
          type = "KMS"
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.key
      dynamic "action" {
        for_each = stage.value
        content {
          name     = action.key
          category = action.value.category
          owner    = action.value.owner
          provider = action.value.provider
          version  = action.value.version

          configuration    = try(action.value.configuration, null)
          input_artifacts  = try(action.value.input_artifacts, null)
          output_artifacts = try(action.value.output_artifacts, null)
          role_arn         = try(action.value.role_arn, null)
          run_order        = try(action.value.run_order, null)
          region           = try(action.value.region, null)
          namespace        = try(action.value.namespace, action.key)
        }
      }
    }
  }
}

module "codepipeline_iam_role" {
  source     = "cloudposse/iam-role/aws"
  version    = "0.16.2"
  context    = module.context.self
  attributes = ["role"]

  assume_role_actions      = ["sts:AssumeRole", "sts:TagSession"]
  assume_role_conditions   = []
  instance_profile_enabled = false
  managed_policy_arns      = []
  max_session_duration     = 3600
  path                     = "/"
  permissions_boundary     = ""
  policy_description       = ""
  policy_document_count    = 1
  policy_documents         = []
  principals = {
    Service = ["codepipeline.amazonaws.com"]
  }
  role_description = "CodePipeline IAM Role for ${module.context.id}"
  tags_enabled     = true
  use_fullname     = true
}

# FIXME
# data "aws_iam_policy_document" "default" {
#   statement {
#     sid = ""

#     actions = [
#       "ec2:*",
#       "elasticloadbalancing:*",
#       "autoscaling:*",
#       "cloudwatch:*",
#       "s3:*",
#       "sns:*",
#       "cloudformation:*",
#       "rds:*",
#       "sqs:*",
#       "ecs:*",
#       "iam:PassRole"
#     ]

#     resources = ["*"]
#     effect    = "Allow"
#   }
# }

# data "aws_iam_policy_document" "s3" {
#   count = module.this.enabled ? 1 : 0

#   statement {
#     sid = ""

#     actions = [
#       "s3:GetObject",
#       "s3:GetObjectVersion",
#       "s3:GetBucketVersioning",
#       "s3:PutObject"
#     ]

#     resources = [
#       join("", aws_s3_bucket.default.*.arn),
#       "${join("", aws_s3_bucket.default.*.arn)}/*"
#     ]

#     effect = "Allow"
#   }
# }
