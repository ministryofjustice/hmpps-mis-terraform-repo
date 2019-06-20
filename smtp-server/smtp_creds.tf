###########################
#Create IAM user for smtp
###########################

resource "aws_iam_user" "ses" {
  name             = "${var.short_environment_identifier}-ses-smtp-user"
  path             = "/"
  force_destroy    = true
  tags             = "${var.tags}"
}

resource "aws_iam_user_policy" "ses" {
  name             = "AmazonSesSendingAccess"
  user             = "${aws_iam_user.ses.name}"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
      "Effect": "Allow",
      "Action": "ses:SendRawEmail",
      "Resource": "*"
    }
  ]
}
EOF
}

locals {
    ses_iam_user      =  "${aws_iam_user.ses.id}"
}
