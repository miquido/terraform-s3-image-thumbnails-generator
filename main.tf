module "label" {
  source = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"

  enabled    = true
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

module "s3-bucket-api-images" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.6.0"

  enabled            = true
  user_enabled       = true
  versioning_enabled = false
  name               = var.name
  namespace          = var.namespace
  stage              = var.stage
  delimiter          = var.delimiter
  attributes         = var.attributes
  sse_algorithm      = "AES256"
  tags               = module.label.tags
}

resource "aws_s3_bucket_notification" "new_object" {
  bucket = module.s3-bucket-api-images.bucket_id

  queue {
    queue_arn     = aws_sqs_queue.new_object.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "original/"
  }
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
          "aws:SourceArn": "${module.s3-bucket-api-images.bucket_arn}"
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
      module.s3-bucket-api-images.bucket_arn,
      "${module.s3-bucket-api-images.bucket_arn}/*",
    ]
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

resource "null_resource" "npm" {
  triggers = {
    main         = filebase64sha256("${path.module}/lambda/index.js")
    requirements = filebase64sha256("${path.module}/lambda/package.json")
  }

  provisioner "local-exec" {
    command     = "docker run -v \"$PWD\":/var/task lambci/lambda:build-nodejs10.x npm install sharp --force"
    working_dir = "${path.module}/lambda"
  }
}

data "external" "zip" {
  program = ["sh", "${path.module}/archive.sh"]

  query = {
    input_path  = "${path.module}/lambda"
    output_path = local.lambda_zip_filename
  }

  depends_on = [null_resource.npm]
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${local.function_name}"
  tags              = module.label.tags
  retention_in_days = 7
}

resource "aws_lambda_function" "default" {
  filename         = data.external.zip.result["output_path"]
  source_code_hash = filebase64sha256(data.external.zip.result["output_path"])
  function_name    = local.function_name
  description      = local.function_name
  runtime          = "nodejs10.x"
  role             = aws_iam_role.default.arn
  handler          = "index.lambda_handler"
  tags             = module.label.tags
  timeout          = 60 # 60 sec
  memory_size      = 512
  environment {
    variables = {
      THUMBNAIL_WIDTHS = join(",", var.thumbnail_widths)
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.default,
    aws_iam_role_policy.default,
    null_resource.npm,
  ]
}

resource "aws_lambda_event_source_mapping" "new_object" {
  event_source_arn = aws_sqs_queue.new_object.arn
  function_name    = aws_lambda_function.default.arn

  #maximum value
  batch_size = 10
}
