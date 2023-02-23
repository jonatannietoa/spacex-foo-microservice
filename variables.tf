variable "PROJECT_NAME" {
  type    = string
  description = "Project Name"
  default = "foo-spacex-simulator"
}

variable "SPRING_PROFILES_ACTIVE" {
  type    = string
  description = "Spring Profile Active"
  default = "dev"
}

variable "aws_region" {
  type    = string
  description = "AWS Region where we deploy resources"
  default = "eu-west-1"
}

variable "AWS_ACCESS_KEY_ID" {
  type    = string
  description = "AWS Account"
  default = "AKIA3YUOZ74U3TWPPNZB"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type    = string
  description = "AWS Key"
  default = "h1Pg0p0wURz7BcRjhwkz3arczeZfIUUgsnuXueEB"
}