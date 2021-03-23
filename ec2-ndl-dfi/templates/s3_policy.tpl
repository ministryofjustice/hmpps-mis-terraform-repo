{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"DfiS3PutPolicy",
      "Effect":"Allow",
    "Principal": {"AWS": "arn:aws:iam::${dfi_account}:root"},
      "Action":["s3:PutObject","s3:PutObjectAcl"],
      "Resource": [
          "arn:aws:s3:::${region}-${environment_name}-dfi-extracts/dfinterventions/dfi/*",
          "arn:aws:s3:::${region}-${environment_name}-dfi-extracts"
      ],
      "Condition":{"StringEquals":{"s3:x-amz-acl":["bucket-owner-full-control"]}}
    },
    {
      "Sid":"DfiS3ListPolicy",
      "Effect":"Allow",
    "Principal": {"AWS": "arn:aws:iam::${dfi_account}:root"},
      "Action":["s3:List*"],
      "Resource": [
          "arn:aws:s3:::${region}-${environment_name}-dfi-extracts/dfinterventions/dfi/*",
          "arn:aws:s3:::${region}-${environment_name}-dfi-extracts"
      ]
    }
  ]
}
