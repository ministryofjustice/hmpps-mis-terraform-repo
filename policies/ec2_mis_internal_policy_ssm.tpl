{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/delius/mis-activedirectory/ad/ad_admin_username"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/delius/mis-activedirectory/ad/ad_admin_password"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/delius/mis-service-accounts/SVC_DS_AD_DEV/SVC_DS_AD_DEV_username"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/delius/mis-service-accounts/SVC_DS_AD_DEV/SVC_DS_AD_DEV_password"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/delius/mis-service-accounts/SVC_BOSSO-NDL/SVC_BOSSO-NDL_username"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:eu-west-2:${account_number}:parameter/${environment_name}/delius/mis-service-accounts/SVC_BOSSO-NDL/SVC_BOSSO-NDL_password"
        }
    ]
}