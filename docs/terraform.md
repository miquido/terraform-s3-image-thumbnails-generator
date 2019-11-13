## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list(string) | `<list>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| name | Solution name, e.g. 'app' or 'cluster' | string | `s3-image-resizer` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | map(string) | `<map>` | no |
| thumbnail_widths | Target widths of generated thumbnails | list(string) | - | yes |
| user_enabled | Whether to create IAM User with RW permissions to created s3 bucket | bool | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| access_key_id | The access key ID |
| bucket_id | Bucket Name (aka ID) |
| secret_access_key | The secret access key. This will be written to the state file in plain-text |

