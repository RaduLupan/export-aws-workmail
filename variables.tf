#----------------------------------------------------------------------------
# REQUIRED PARAMETERS: You must provide a value for each of these parameters.
#----------------------------------------------------------------------------

variable "region" {
  description = "AWS region where your WorkMail Organization resides"
  type        = string
}

#---------------------------------------------------------------
# OPTIONAL PARAMETERS: These parameters have resonable defaults.
#---------------------------------------------------------------

variable "s3_prefix" {
  description = "Prefix to use for the S3 bucket name"
  type        = string
  default     = "aws-workmail-export"
}
