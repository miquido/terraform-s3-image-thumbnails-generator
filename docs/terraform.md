## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list(string) | `<list>` | no |
| bucket_enabled | Whether to create S3 Bucket. If value is `false`, the argument `bucket_id` is required. | bool | `true` | no |
| bucket_id | The ID of S3 Bucket to use. If provided module won't create S3 bucket itself. Required if `bucket_enabled=false`. | string | `` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| log_retention | Specifies the number of days you want to retain log events in the specified log group | number | `7` | no |
| name | Solution name, e.g. 'app' or 'cluster' | string | `s3-image-resizer` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| s3_acl | The canned ACL to apply. Defaults to `public-read`. See: https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | string | `public-read` | no |
| s3_region | The AWS Region where S3 Bucket is created or should be created. By default it is the region of current AWS provider. | string | `` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | map(string) | `<map>` | no |
| thumbnail_widths | Target widths of generated thumbnails | list(string) | - | yes |
| user_enabled | Whether to create IAM User with RW permissions to created s3 bucket. Ignored when `bucket_enabled=false`. | bool | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| access_key_id | The access key ID |
| bucket_id | Bucket Name (aka ID) |
| secret_access_key | The secret access key. This will be written to the state file in plain-text |

