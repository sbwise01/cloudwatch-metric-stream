resource "aws_cloudwatch_metric_stream" "main" {
  name_prefix   = "${var.application}-${var.environment}"
  role_arn      = aws_iam_role.metric_stream_to_firehose.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.s3_stream.arn
  output_format = var.output_format
  tags          = var.tags

  dynamic "include_filter" {
    for_each = toset(var.include_namespaces)
    content {
      namespace = include_filter.value
    }
  }

  dynamic "exclude_filter" {
    for_each = toset(var.exclude_namespaces)
    content {
      namespace = exclude_filter.value
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "s3_stream" {
  name        = "${var.application}-cloudwatch-metric-stream-${var.environment}"
  destination = "s3"
  tags        = var.tags
  
  s3_configuration {
    buffer_interval    = var.buffer_interval
    buffer_size        = var.buffer_size
    compression_format = var.output_compression
    prefix             = var.prefix
    role_arn           = aws_iam_role.firehose_to_s3.arn
    bucket_arn         = aws_s3_bucket.metric-stream.arn

    cloudwatch_logging_options {
      enabled         = var.s3_logging
      log_group_name  = var.s3_logging ? "${var.application}-cloudwatch-metric-stream-${var.environment}" : null
      log_stream_name = var.s3_logging ? "S3Delivery" : null
    }
  }
}


resource "aws_cloudwatch_log_group" "s3_stream" {
  count = var.s3_logging ? 1 : 0

  name = "${var.application}-cloudwatch-metric-stream-${var.environment}"
  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "s3_stream" {
  count = var.s3_logging ? 1 : 0

  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.s3_stream[count.index].name
}
