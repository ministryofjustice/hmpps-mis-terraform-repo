vpc_supernet = "10.161.99.0/24"

# VPC variables
cloudwatch_log_retention = 14

public-cidr = {
  az1 = "10.161.99.0/27"

  az2 = "10.161.99.32/27"

  az3 = "10.161.99.64/27"
}

private-cidr = {
  az1 = "10.161.99.96/27"

  az2 = "10.161.99.128/27"

  az3 = "10.161.99.160/27"
}

db-cidr = {
  az1 = "10.161.99.208/28"

  az2 = "10.161.99.224/28"

  az3 = "10.161.99.240/28"
}

aws_nameserver = "10.161.99.2"

public_ssl_arn = "arn:aws:acm:eu-west-2:723123699647:certificate/0b97aef6-3c80-48c2-818c-855d493b2d81"

# ENVIRONMENT REMOTE STATES
eng-remote_state_bucket_name = "tf-eu-west-2-hmpps-eng-dev-remote-state"

# ENVIRONMENT ROLE ARNS
eng_role_arn = "arn:aws:iam::895523100917:role/terraform"

eng_root_arn = "arn:aws:iam::895523100917:root"

# ROUTE53 ZONE probation.hmpps.dsd.io
route53_hosted_zone_id = "Z2UWMKJVW764KQ"
