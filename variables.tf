variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = string
  default     = "s3-image-resizer"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "thumbnail_widths" {
  type        = list(string)
  description = "Target widths of generated thumbnails"
}

variable "user_enabled" {
  type        = bool
  default     = true
  description = "Whether to create IAM User with RW permissions to created s3 bucket. Ignored when `bucket_enabled=false`."
}

variable "s3_region" {
  type        = string
  default     = ""
  description = "The AWS Region where S3 Bucket is created or should be created. By default it is the region of current AWS provider."
}

variable "s3_acl" {
  type        = string
  default     = "private"
  description = "The canned ACL to apply. Defaults to `private`. See: https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl"
}

variable "bucket_enabled" {
  type        = bool
  default     = true
  description = "Whether to create S3 Bucket. If value is `false`, the argument `bucket_id` is required."
}

variable "bucket_versioning_enabled" {
  type        = bool
  default     = true
  description = "Whether to turn bucket versioning on"
}

variable "bucket_id" {
  type        = string
  default     = ""
  description = "The ID of S3 Bucket to use. If provided module won't create S3 bucket itself. Required if `bucket_enabled=false`."
}

variable "log_retention" {
  type        = number
  default     = 7
  description = "Specifies the number of days you want to retain log events in the specified log group"
}
