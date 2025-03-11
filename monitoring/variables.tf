variable "ec2_autoscaling_group_name" {
  type = string
  description = "The name of the ec2 autoscaling group."
}

variable "rds_db_instance_identifier" {
  type = string
  description = "The identifier of the rds instance."
}

variable "cloudtrail_bucket_name" {
  type = string
  description = "The name of the s3 bucket used for cloudtrail logs."
}
