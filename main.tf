module "label" {
  source = "git::https://github.com/cloudposse/terraform-terraform-label.git"

  enabled    = true
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

module "s3-bucket-api-images" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git"

  enabled            = var.bucket_enabled
  user_enabled       = var.user_enabled
  versioning_enabled = var.bucket_versioning_enabled
  name               = var.name
  namespace          = var.namespace
  stage              = var.stage
  delimiter          = var.delimiter
  attributes         = var.attributes
  sse_algorithm      = "AES256"
  tags               = module.label.tags
}

locals {
  s3_bucket_images_id  = var.bucket_enabled ? module.s3-bucket-api-images.bucket_id : var.bucket_id
  s3_bucket_images_arn = var.bucket_enabled ? module.s3-bucket-api-images.bucket_arn : "arn:aws:s3:::${var.bucket_id}"
}

resource "aws_s3_bucket_notification" "new_object" {
  bucket = local.s3_bucket_images_id

  queue {
    queue_arn     = aws_sqs_queue.new_object.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "original/"
  }
  depends_on = [aws_lambda_permission.s3_notification]
}

resource "aws_sqs_queue" "new_object" {
  name = module.label.id

  message_retention_seconds = 86400 # 1 day

  # based on https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html
  # set the source queue's visibility timeout to at least 6 times the timeout that you configure on your function
  # lambda reads events in batch up to 10
  # it takes 1 min per event
  # 10 * 1 min * 6 = 60 min
  visibility_timeout_seconds = 3600 # 60 min

  # based on https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html
  # Set the maxReceiveCount on the queue's redrive policy to at least 5 to avoid sending messages to the dead-letter queue due to throttling.
  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${aws_sqs_queue.new_object_deadletter.arn}",
    "maxReceiveCount": 5
  }

EOF


  tags = module.label.tags
}

#let's s3 send events to this queue
resource "aws_sqs_queue_policy" "s3_send_message_2_sqs" {
  queue_url = aws_sqs_queue.new_object.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "s3NewObjectToSQS",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.new_object.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${local.s3_bucket_images_arn}"
        }
      }
    }
  ]
}
EOF

}

resource "aws_sqs_queue" "new_object_deadletter" {
  name = "${module.label.id}-deadletter"

  message_retention_seconds = 864000 # 10 days

  tags = module.label.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]

    effect = "Allow"

    resources = [aws_sqs_queue.new_object.arn]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketLocation",
      "s3:AbortMultipartUpload",
    ]

    effect = "Allow"

    resources = [
      local.s3_bucket_images_arn,
      "${local.s3_bucket_images_arn}/*",
    ]
  }

  statement {
    actions = [
      "sns:Publish",
      "sns:Subscribe"
    ]

    effect = "Allow"

    resources = [
      aws_sns_topic.image_thumbnails_generated.arn
    ]
  }

  statement {
    actions = [
      "sns:Subscribe",
      "sns:Receive"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

locals {
  function_name       = module.label.id
  lambda_zip_filename = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "default" {
  name               = local.function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "default" {
  name   = local.function_name
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.default.json
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${local.function_name}"
  tags              = module.label.tags
  retention_in_days = var.log_retention
}

data "aws_region" "current" {}

resource "aws_sns_topic" "image_thumbnails_generated" {
  name = "image-thumbnails-generated-topic"
}

resource "aws_lambda_function" "default" {
  filename         = local.lambda_zip_filename
  source_code_hash = filebase64sha256(local.lambda_zip_filename)
  function_name    = local.function_name
  description      = local.function_name
  runtime          = "nodejs14.x"
  role             = aws_iam_role.default.arn
  handler          = "index.lambda_handler"
  tags             = module.label.tags
  timeout          = 60 # 60 sec
  memory_size      = 1024
  environment {
    variables = {
      S3_REGION        = var.s3_region == "" ? data.aws_region.current.name : var.s3_region
      S3_ACL           = var.s3_acl
      THUMBNAIL_WIDTHS = join(",", var.thumbnail_widths)
      S3_ENCRYPTION    = "AES256"
      SNS_TOPIC_ARN    = aws_sns_topic.image_thumbnails_generated.arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.default,
    aws_iam_role_policy.default
  ]
}

resource "aws_lambda_event_source_mapping" "new_object" {
  event_source_arn = aws_sqs_queue.new_object.arn
  function_name    = aws_lambda_function.default.arn

  #maximum value
  batch_size = 10
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "s3_notification" {
  statement_id   = "AllowExecutionS3Notification"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.default.arn
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = local.s3_bucket_images_arn
}
