provider "aws" {
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::246402711611:role/AdministratorAccess"
  }
}

module "s3-image-resizer" {
  source = "../../"

  namespace                 = "playground"
  stage                     = "9642-e1be1023670c"
  name                      = "image-resizer"
  thumbnail_widths          = [1200, 800, 600, 400, 200]
  user_enabled              = true
  s3_region                 = "eu-central-1"
  s3_acl                    = "private"
  bucket_enabled            = true
  bucket_versioning_enabled = true
  log_retention             = 30

  tags = {
    Terraformed = "true"
  }
}
