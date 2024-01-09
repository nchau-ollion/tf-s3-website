variable  "aws_region" {
    type    = string
    default = "us-west-1"
}

variable "resource_tags" {
  description   = "Tags to set for all resources"
  type          = map(string)
  default = {
    Name        = "nchau"
    Project     = "Terraform", 
    # autopark    = "M-F 9-5"   future development
  }
}