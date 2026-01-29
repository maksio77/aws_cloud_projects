data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

locals {
  instances = {
    "red" = {
      "script" = "scripts/userdata_red.sh"
      "az"     = "eu-central-1a"
    }
    "blue" = {
      "script" = "scripts/userdata_blue.sh"
      "az"     = "eu-central-1b"
    }
  }
}

data "aws_subnet" "selected" {
  for_each = toset([for k, v in local.instances : v.az])

  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.key
}

resource "aws_instance" "terraform_web_instance" {
  for_each = local.instances

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.WebsiteSG.id]
  user_data                   = file("${path.module}/${each.value.script}")
  subnet_id                   = data.aws_subnet.selected[each.value.az].id
  iam_instance_profile        = aws_iam_instance_profile.S3-ARR-Profile.name

  tags = {
    Name = each.key
  }
}

resource "aws_lb_target_group" "app_tgs" {
  for_each = local.instances

  name     = "tf-tg-${each.key}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "tgs_attachment" {
  for_each = local.instances

  target_group_arn = aws_lb_target_group.app_tgs[each.key].arn
  target_id        = aws_instance.terraform_web_instance[each.key].id

  port = 80
}

resource "aws_lb" "web_alb" {
  name               = "tf-example-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.WebsiteSG.id]
  subnets         = [for s in data.aws_subnet.selected : s.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tgs["blue"].arn
  }
}

resource "aws_lb_listener_rule" "red_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tgs["red"].arn
  }
  condition {
    path_pattern {
      values = ["/red*"]
    }
  }
}

resource "aws_lb_listener_rule" "blue_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tgs["blue"].arn
  }
  condition {
    path_pattern {
      values = ["/blue*"]
    }
  }
}
