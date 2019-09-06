output "secret_access_key" {
  description = "The secret access key. This will be written to the state file in plain-text"
  value       = "${module.s3-bucket-api-images.secret_access_key}"
}

output "access_key_id" {
  description = "The access key ID"
  value       = "${module.s3-bucket-api-images.access_key_id}"
}

output "bucket_id" {
  description = "Bucket Name (aka ID)"
  value       = "${module.s3-bucket-api-images.bucket_id}"
}

