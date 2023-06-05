resource "aws_s3_bucket" "metric-stream" {
  bucket = "${var.application}-cloudwatch-metric-stream-${var.environment}"
  tags   = var.tags  
}

resource "aws_s3_bucket_acl" "metric-stream" {
  bucket = aws_s3_bucket.metric-stream.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "metric-stream" {
  bucket = aws_s3_bucket.metric-stream.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:AbortMultipartUpload"
     ]

    resources = [
      aws_s3_bucket.metric-stream.arn,
      "${aws_s3_bucket.metric-stream.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose_to_s3.arn]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "true"
      ]
    }
  }

  statement {
    actions = [
      "s3:List*",
      "s3:Get*"
    ]

    resources = [
      aws_s3_bucket.metric-stream.arn,
      "${aws_s3_bucket.metric-stream.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = var.bucket_iam_role_arns
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "true"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "metric-stream" {
  bucket = aws_s3_bucket.metric-stream.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}
