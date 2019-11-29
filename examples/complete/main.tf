provider "aws" {
  region = "eu-central-1"
}


module "s3-image-resizer" {
  source = "../../"

  namespace        = "example"
  stage            = "test"
  thumbnail_widths = [1200, 800, 600, 400, 200]

}
