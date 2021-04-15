{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "codepipeline:StartPipelineExecution",
            "Resource": "arn:aws:codepipeline:${region}:${account_id}:${environment_name}-dfi-s3-fsx"
        }
    ]
}
