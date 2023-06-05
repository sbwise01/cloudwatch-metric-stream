data "aws_iam_policy_document" "metric_stream_to_firehose_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "streams.metrics.cloudwatch.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "metric_stream_to_firehose" {
  name               = "${var.application}-metric-stream-to-firehose-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.metric_stream_to_firehose_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "metric_stream_to_firehose_policy" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.s3_stream.arn
    ]
  }
}

resource "aws_iam_role_policy" "metric_stream_to_firehose" {
  name   = "${var.application}-metric-stream-to-firehose-${var.environment}"
  role   = aws_iam_role.metric_stream_to_firehose.id
  policy = data.aws_iam_policy_document.metric_stream_to_firehose_policy.json
}

data "aws_iam_policy_document" "firehose_to_s3_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "firehose_to_s3" {
  name               = "${var.application}-firehose-to-s3-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.firehose_to_s3_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "firehose_to_s3_policy" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.metric-stream.arn,
      "${aws_s3_bucket.metric-stream.arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = toset(aws_cloudwatch_log_group.s3_stream.*.arn)
    content {
      actions = [
        "logs:PutLogEvents"
      ]

      resources = [
        "${statement.value}:log-stream:S3Delivery"
      ]
    }
  }

  # statement {
  #     actions = [
  #         "logs:PutLogEvents"
  #     ],
  #     resources = [
  #         "arn:aws:logs:us-east-1:238080251717:log-group:/aws/kinesisfirehose/MetricStreams-QuickFull-QTVXei-b7HJKpEy:log-stream:S3Delivery"
  #"        "arn:aws:logs:us-east-1:238080251717:log-group:brad-cloudwatch-metric-stream-dev"
  #     ]
  # }
}

resource "aws_iam_role_policy" "firehose_to_s3" {
  name   = "${var.application}-firehose-to-s3-${var.environment}"
  role   = aws_iam_role.firehose_to_s3.id
  policy = data.aws_iam_policy_document.firehose_to_s3_policy.json
}
