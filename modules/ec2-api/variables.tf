variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups for the API instance."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "Optional AMI override (defaults to Amazon Linux 2023 x86_64)."
  default     = null
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair for SSH."
  default     = null
}

variable "api_port" {
  type        = number
  description = "Application listen port behind nginx."
  default     = 8080
}

variable "root_volume_size_gb" {
  type        = number
  description = "Root gp3 volume size in GB."
  default     = 8
}

variable "additional_iam_policy_arns" {
  type        = list(string)
  description = "Extra IAM policy ARNs to attach to the API instance role (e.g. RDS SSM read)."
  default     = []
}
