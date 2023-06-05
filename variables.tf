variable "application" {
  type        = string
  description = "Identity of application used to make resource names unique"
}

variable "environment" {
  type        = string
  description = "Identity of environment used to make resource names unique"
}

variable "bucket_iam_role_arns" {
  type        = list(string)
  description = "List of IAM Role ARNs to grant access to the bucket"
  default     = []
}

variable "output_format" {
  type        = string
  description = "Format of output written to S3 by Cloudwatch metric stream.  Valid values are [opentelemetry0.7|json].  Default opentelemetry0.7"
  default     = "opentelemetry0.7"
}

variable "output_compression" {
  type        = string
  description = "Type of compression algorithm to use on S3 output.  Passing null means no compression.  Valid values are [GZIP|ZIP|Snappy|HADOOP_SNAPPY]. Default GZIP"
  default     = "GZIP"
}

variable "buffer_interval" {
  type        = number
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to S3. Default 60"
  default     = 60
}

variable "buffer_size" {
  type        = number
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to S3. Default 5"
  default     = 5
}

variable "prefix" {
  type        = string
  description = "An extra prefix to be added in front of the time format prefix for each S3 object. Defaul null"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to provisioned resources.  Default empty"
  default     = {}
}

variable "include_namespaces" {
  type        = list(string)
  description = "List of Cloudwatch namespaces (i.e. AWS/EC2) to specifically include in the metric stream.  If empty, stream will include all namespaces.  Default empty"
  default     = []
}

variable "exclude_namespaces" {
  type        = list(string)
  description = "List of Cloudwatch namespaces (i.e. AWS/EC2) to specifically exclude in the metric stream. Default empty"
  default     = []
}

variable "s3_logging" {
  type        = bool
  description = "Create Cloudwatch logs for S3 events from Kinesis Firehose.  Default true"
  default     = true
}
