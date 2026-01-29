output "instance_public_ip" {
  description = "Публічна IP адреса EC2 інстансу"
  value       = aws_instance.terraform_web_instance.public_ip
}