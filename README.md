<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![Miquido][logo]](https://www.miquido.com/)

# terraform-s3-image-thumbnails-generator


---
**Terraform Module**


GitLab Repository: https://gitlab.com/miquido/terraform/terraform-s3-image-thumbnails-generator

## Usage


Terraform:

```hcl
module "s3-image-resizer" {
  source = "git::ssh://git@gitlab.com:miquido/terraform/terraform-s3-image-thumbnails-generator.git?ref=master"

  namespace        = "${var.project}"
  stage            = "${var.environment}"
  thumbnail_widths = [1200,800,600,400,200]

  namespace                 = var.project
  stage                     = var.environment
  name                      = "image-resizer"
  thumbnail_widths          = [1200, 800, 600, 400, 200]
  user_enabled              = false
  s3_region                 = var.aws_region
  s3_acl                    = "private"
  bucket_enabled            = true
  bucket_versioning_enabled = true
  log_retention             = 7
  tags                      = var.tags
}
```

### Building lambda

## Warning: This process requires x86 compatible machine (does not work currently on ARM).

1. Edit files in `src/` directory
2. Run script:

```sh
make lint
make build/lambda-zip
make build/lambda-layer-zip
```
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.16 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/terraform | 0.8.0 |
| <a name="module_s3-bucket-api-images"></a> [s3-bucket-api-images](#module\_s3-bucket-api-images) | cloudposse/s3-bucket/aws | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_event_source_mapping.new_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.lambda_layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_permission.s3_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.new_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_sns_topic.image_thumbnails_generated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sqs_queue.new_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.new_object_deadletter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.s3_send_message_2_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_bucket_enabled"></a> [bucket\_enabled](#input\_bucket\_enabled) | Whether to create S3 Bucket. If value is `false`, the argument `bucket_id` is required. | `bool` | `true` | no |
| <a name="input_bucket_id"></a> [bucket\_id](#input\_bucket\_id) | The ID of S3 Bucket to use. If provided module won't create S3 bucket itself. Required if `bucket_enabled=false`. | `string` | `""` | no |
| <a name="input_bucket_versioning_enabled"></a> [bucket\_versioning\_enabled](#input\_bucket\_versioning\_enabled) | Whether to turn bucket versioning on | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Specifies the number of days you want to retain log events in the specified log group | `number` | `7` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'cluster' | `string` | `"s3-image-resizer"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| <a name="input_s3_acl"></a> [s3\_acl](#input\_s3\_acl) | The canned ACL to apply. Defaults to `private`. See: https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | `string` | `"private"` | no |
| <a name="input_s3_region"></a> [s3\_region](#input\_s3\_region) | The AWS Region where S3 Bucket is created or should be created. By default it is the region of current AWS provider. | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_thumbnail_widths"></a> [thumbnail\_widths](#input\_thumbnail\_widths) | Target widths of generated thumbnails | `list(string)` | n/a | yes |
| <a name="input_user_enabled"></a> [user\_enabled](#input\_user\_enabled) | Whether to create IAM User with RW permissions to created s3 bucket. Ignored when `bucket_enabled=false`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | The access key ID |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket Name (aka ID) |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | The secret access key. This will be written to the state file in plain-text |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | SNS topic for newly uploaded files |
<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Makefile Targets
```text
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen

```
<!-- markdownlint-restore -->


## Developing

1. Make changes in terraform files

2. Regenerate documentation

    ```bash
    bash <(git archive --remote=git@gitlab.com:miquido/terraform/terraform-readme-update.git master update.sh | tar -xO)
    ```

3. Run lint

    ```
    make lint
    ```

## Copyright

Copyright © 2017-2023 [Miquido](https://miquido.com)



### Contributors

|  [![Paweł Jędruch][pawcik_avatar]][pawcik_homepage]<br/>[Paweł Jędruch][pawcik_homepage] | [![Konrad Obal][k911_avatar]][k911_homepage]<br/>[Konrad Obal][k911_homepage] |
|---|---|

  [pawcik_homepage]: https://github.com/pawcik
  [pawcik_avatar]: https://github.com/pawcik.png?size=150
  [k911_homepage]: https://github.com/k911
  [k911_avatar]: https://github.com/k911.png?size=150



  [logo]: https://www.miquido.com/img/logos/logo__miquido.svg
  [website]: https://www.miquido.com/
  [gitlab]: https://gitlab.com/miquido
  [github]: https://github.com/miquido
  [bitbucket]: https://bitbucket.org/miquido

