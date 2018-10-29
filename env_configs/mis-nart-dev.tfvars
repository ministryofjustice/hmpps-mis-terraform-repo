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

cross_account_iam_role = "arn:aws:iam::895523100917:role/tf-eu-west-2-hmpps-eng-dev-mis-runtime"

# ROUTE53 ZONE probation.hmpps.dsd.io
route53_hosted_zone_id = "Z2UWMKJVW764KQ"

# ALLOWED CIDRS
allowed_cidr_block = [
  "51.148.142.120/32",  #Brett Home
  "109.148.158.168/32", #Don Home
  "81.134.202.29/32",   #Moj VPN
  "217.33.148.210/32",  #Digital studio
  "35.176.14.16/32",    #Engineering Jenkins non prod AZ 1
  "35.177.83.160/32",   #Engineering Jenkins non prod AZ 2
  "18.130.108.149/32",  #Engineering Jenkins non prod AZ 3
  "194.75.210.218/32",  #MIS Tolomy
]
