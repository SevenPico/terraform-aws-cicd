variable "ecr_repository_url_map" {
  type    = map(string)
  default = {}
}

variable "s3_bucket_ids" {
  type    = list(string)
  default = []
}

variable "sns_pub_principals" {
  type    = map(list(string))
  default = {}
}

variable "sns_sub_principals" {
  type    = map(list(string))
  default = {}
}
