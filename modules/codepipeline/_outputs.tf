output "arn" {
  value = try(aws_codepipeline.this[0].arn, "")
}

output "id" {
  value = try(aws_codepipeline.this[0].id, "")
}

output "role_arn" {
  value = module.codepipeline_iam_role.arn
}
