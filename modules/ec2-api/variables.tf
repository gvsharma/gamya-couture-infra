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

variable "app_path" {
  type        = string
  description = "Application root on the instance (deploy paths, systemd)."
  default     = "/opt/gamya-couture"
}

variable "db_endpoint" {
  type        = string
  description = "RDS hostname for application.env bootstrap template."
  default     = ""
}

variable "db_name" {
  type        = string
  description = "PostgreSQL database name for application.env bootstrap template."
  default     = "gamya"
}

variable "db_username" {
  type        = string
  description = "PostgreSQL username for application.env bootstrap template."
  default     = "gamya_admin"
}

variable "root_volume_size_gb" {
  type        = number
  description = "Root gp3 volume size in GB."
  default     = 8
}

variable "db_parameter_store_prefix" {
  type        = string
  description = "SSM path prefix for DB credentials (e.g. /gamya-couture/dev/db). Grants read on username/password parameters."
  default     = ""
}

variable "additional_iam_policy_arns" {
  type        = map(string)
  description = "Extra IAM policy ARNs to attach to the API instance role. Use static map keys (values may be apply-time)."
  default     = {}
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "Public SSH keys appended to ec2-user authorized_keys at launch (cloud-init). Use for GitHub Actions deploy keys."
  default     = []

  validation {
    condition = alltrue([
      for key in var.ssh_authorized_keys :
      can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp256) ", key))
    ])
    error_message = "Each ssh_authorized_keys entry must be a full public key line (ssh-ed25519, ssh-rsa, or ecdsa-sha2-nistp256)."
  }
}

variable "user_data_replace_on_change" {
  type        = bool
  description = "Replace the instance when user_data changes. Enable when ssh_authorized_keys must apply to an existing host."
  default     = false
}
