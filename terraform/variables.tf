variable "aws_region" {
  description = "AWS Region"
  default     = "eu-west-3"
}

variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "cloudflare zone id"
  type        = string
}

variable "cloudflare_api_token" {
  description = "cloudflare api token"
  type        = string
  sensitive   = true
}

variable "public_key_path" {
  description = "path to public SSH key"
  default     = "~/.ssh/tf-lab-key.pub"
}