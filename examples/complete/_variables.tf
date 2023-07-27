variable "vpc_cidr_block" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}

variable "acm_certificate_arn" {
  type = string
}