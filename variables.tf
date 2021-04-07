variable "vpc_id" {
  default = "vpc-03f094db73a5298e9"
}

variable "amiid" {
  description = "AMI ID of the instance"
  default     = "ami-0742b4e673072066f"
  type        = string
}

variable "tags" {
  default = ["DL_APP", "RT_APP"]
}

variable "instance_count" {
  default = 2
}