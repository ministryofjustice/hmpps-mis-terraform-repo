###########################
#Create IAM user for smtp
###########################

resource "aws_iam_user" "ses" {
  name             = "${var.short_environment_identifier}-ses-smtp-user"
  path             = "/"
  force_destroy    = true
  tags             = "${var.tags}"
}

resource "aws_iam_access_key" "ses" {
  user             = "${aws_iam_user.ses.name}"
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


###SMTP Password in Param store
#################################

resource "aws_ssm_parameter" "smtp_password" {
    name             = "${aws_iam_user.ses.id}-ses-password"
    type             = "SecureString"
    description      = "${aws_iam_user.ses.id}-ses-password"
    overwrite        = "true"
    value            = "${aws_iam_access_key.ses.ses_smtp_password}"
}

###SMTP User in param store
################################
resource "aws_ssm_parameter" "smtp_user" {
    name             = "${aws_iam_user.ses.id}-access-key-id"
    type             = "SecureString"
    description      = "${aws_iam_user.ses.id}-access-key-id"
    value            = "${aws_iam_access_key.ses.id}"
}

locals {
    ses_user_id       = "${aws_iam_access_key.ses.id}"
    ses_smtp_password = "${aws_iam_access_key.ses.ses_smtp_password}"
}
