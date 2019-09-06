<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![Miquido][logo]](https://www.miquido.com/)

# miquido-node-image-resizer-lambda
---
Terraform Module

BitBucket Repository: https://bitbucket.org/miquido-node-image-resizer-lambda
## Usage


Terraform:

```hcl
module {
  source              = "git::ssh://git@bitbucket.org/miquido/miquido-node-image-resizer-lambda.git?ref=master"
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| name | Solution name, e.g. 'app' or 'cluster' | string | `s3-image-resizer` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| access_key_id | The access key ID |
| bucket_id | Bucket Name (aka ID) |
| secret_access_key | The secret access key. This will be written to the state file in plain-text |

## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```


## Developing

1. Make changes in terraform files

2. Regerate documentation

    ```bash
    bash <(curl -s https://terraform.s3.k.miquido.net/update.sh)
    ```

3. Run lint

    ```
    make lint
    ```

## Copyright

Copyright © 2017-2019 [Miquido](https://miquido.com)



### Contributors

|  [![Paweł Jędruch][pawcik_avatar]][pawcik_homepage]<br/>[Paweł Jędruch][pawcik_homepage] |
|---|

  [pawcik_homepage]: https://github.com/pawcik
  [pawcik_avatar]: https://github.com/pawcik.png?size=150



  [logo]: https://www.miquido.com/img/logos/logo__miquido.svg
  [website]: https://www.miquido.com/
  [github]: https://github.com/miquido
  [bitbucket]: https://bitbucket.org/miquido
