data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "terraform_web_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.terraform_sg.id]
  key_name                    = "my-key"
  user_data                   = templatefile("templates/custom_web_page.sh", {})

  tags = {
    Name = "WebServerInstance-tr"
  }
}
