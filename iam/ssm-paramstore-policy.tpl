{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/${application_name}elius/mis-activedirectory/ad/ad_admin_username"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/${application_name}/mis-activedirectory/ad/ad_admin_password"
        }
    ]
}