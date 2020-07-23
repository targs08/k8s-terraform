

variable "period" {
  type = string
  // Default is 3 years
  default = 26280
}

variable "s3" {
  type = object({
    enabled = bool
    bucket = string
    path = string
  })

  default = {
    enabled = false
    bucket = ""
    path = ""
  }

  description = "Upload to s3"
}