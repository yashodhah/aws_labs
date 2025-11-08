variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "multi-region-http"
}

variable "primary_region" {
  description = "Primary AWS region for default provider"
  type        = string
  default     = "ap-southeast-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for aliased provider"
  type        = string
  default     = "us-east-1"
}

variable "http_integration_uri" {
  description = "The upstream HTTP endpoint to proxy (for demo purposes)"
  type        = string
  default     = "https://httpbin.org/anything"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Terraform   = "true"
    Project     = "networking-multi-region"
    Environment = "dev"
  }
}
