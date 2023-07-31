resource "random_string" "random" {
  length  = 15
  special = false
  lower   = true
  numeric = true
  upper   = false
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "bootstrap-VM-S3-role-${random_string.random.id}"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name = "bootstrap-VM-S3-policy-${random_string.random.id}"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["s3:ListBucket"],
          "Resource" : ["arn:aws:s3:::${aws_s3_bucket.this.id}"]
        },
        {
          "Effect" : "Allow",
          "Action" : ["s3:GetObject"],
          "Resource" : ["arn:aws:s3:::${aws_s3_bucket.this.id}/*"]
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "bootstrap-VM-S3-role-${random_string.random.id}"
  role = aws_iam_role.this.id
}

resource "aws_s3_bucket" "this" {
  bucket = "bootstrap${random_string.random.id}"
  tags = {
    Name = "bootstrap${random_string.random.id}"
  }
}


resource "aws_s3_object" "config" {
  key    = "config/"
  bucket = aws_s3_bucket.this.id
}

resource "aws_s3_object" "content" {
  key    = "content/"
  bucket = aws_s3_bucket.this.id
}

resource "aws_s3_object" "license" {
  key    = "license/"
  bucket = aws_s3_bucket.this.id
}

resource "aws_s3_object" "software" {
  key    = "software/"
  bucket = aws_s3_bucket.this.id
}

resource "aws_s3_object" "init_cfg" {
  bucket = aws_s3_bucket.this.id
  key    = "config/init-cfg.txt"
  acl    = "private"
  source = "${path.module}/init-cfg.txt"
  etag   = filemd5("${path.module}/init-cfg.txt")
}

resource "aws_s3_object" "bootstrap_xml" {
  bucket = aws_s3_bucket.this.id
  key    = "config/bootstrap.xml"
  acl    = "private"
  source = "${path.module}/bootstrap.xml"
  etag   = filemd5("${path.module}/bootstrap.xml")
}
