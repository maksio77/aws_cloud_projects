variable "aws_region" {
  description = "AWS регіон для розгортання"
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Тип EC2 інстансу"
  default     = "t2.micro"
}
