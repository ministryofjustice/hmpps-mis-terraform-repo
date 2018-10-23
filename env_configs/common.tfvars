region = "eu-west-2"

availability_zone = {
  az1 = "eu-west-2a"
  az2 = "eu-west-2b"
  az3 = "eu-west-2c"
}

route53_domain_private = "probation.hmpps.dsd.io"

mis_app_name = "mis"

allowed_ssh_cidr = [
  "51.148.142.120/32",  #Brett Home
  "109.148.137.148/32", #Don Home
  "81.134.202.29/32",   #Moj VPN
  "217.33.148.210/32",
] #Digital studio

allowed_ip_cidr = [
  # Github
  "192.30.252.0/22",

  "185.199.108.0/22",
  "140.82.112.0/20",
  "13.229.188.59/32",
  "13.250.177.223/32",
  "18.194.104.89/32",
  "18.195.85.27/32",
  "35.159.8.160/32",
  "52.74.223.119/32",
  "217.33.148.210/32",
]

# This is used for ALB logs to S3 bucket.
# This is fixed for each region. if region changes, this changes
lb_account_id = "652711504416"
