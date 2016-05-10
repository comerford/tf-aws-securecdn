#
# General variables file
#
# Variables need to be defined even though they are loaded from
# terraform.tfvars - see https://github.com/hashicorp/terraform/issues/2659

variable "access_origin_id" {
    default = "ABCDEFABCDEF"
}

variable "s3_origin_id" {
    defaul = "S3-www.example.com"
}

variable "tag_Owner" {
    default = "yourteam@example.com"
}

variable "tag_Name" {
    default = "secure-cdn"
}

variable "aws_region" {
    default = "eu-west-1"
}

variable "acm_ssl_cert" {
    default = "arn:aws:iam::111111111111:server-certificate/example.com"
}

variable "bucket_name" {
    default = "cdn.example.com"
}

variable "origin_domain_name" {
    default = "cdn.example.com"
}

variable "domain_aliases" {
    default = "cdn.example.com,images.example.com"
}

variable "cname_aliases" {
    default = "cdn.example.com,images.example.com"
}

variable "domain_zone_id" {
    default = "ZXZXZXZXZXZ"
}
