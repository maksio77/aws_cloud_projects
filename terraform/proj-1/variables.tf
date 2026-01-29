variable "aws_region" {
  description = "AWS регіон для розгортання"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR блок для VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR блок для публічної підмережі"
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Тип EC2 інстансу"
  default     = "t3.micro"
}
