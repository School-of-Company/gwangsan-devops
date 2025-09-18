variable "prefix" {
  default = "gwangsan"
}

variable "region" {
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  default = "default"
}


variable "enable_http" {
  description = "Whether to enable HTTP listener"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Whether to enable HTTPS listener"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ARN of ACM certificate"
  type        = string
  default = null
}