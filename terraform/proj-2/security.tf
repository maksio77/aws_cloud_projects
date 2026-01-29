resource "aws_security_group" "WebsiteSG" {
  name        = "WebsiteSG"
  description = "WebsiteSG"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "WebsiteSG"
  }
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.WebsiteSG.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.WebsiteSG.id
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "S3_ARR_Role" {
  name               = "S3-ARR-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "S3-ARR-Policy" {
  name = "S3-ARR-Role"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "arn:aws:s3:::arr-bucket-test/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.S3_ARR_Role.name
  policy_arn = aws_iam_policy.S3-ARR-Policy.arn
}

resource "aws_iam_instance_profile" "S3-ARR-Profile" {
  name = "S3-ARR-Profile"
  role = aws_iam_role.S3_ARR_Role.name
}
