{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DfiS3PutPolicy",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${dfi_account}:root"
      },
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts/dfinterventions/dfi/*",
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts"
      ],
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": [
            "bucket-owner-full-control"
          ]
        }
      }
    },
    {
      "Sid": "DfiS3ListPolicy",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${dfi_account}:root"
      },
      "Action": [
        "s3:List*",
        "s3:DeleteObject*",
        "s3:GetObject*",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts/dfinterventions/dfi/*",
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts"
      ]
    },
%{ if dfi_mp_datasync_s3_role != null }
    {
      "Sid": "DataSyncReadPolicy",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${dfi_mp_datasync_s3_role}"
        ]
      },
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:GetBucketVersioning",
        "s3:GetObject",
        "s3:GetObjectTagging",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectAcl",
        "s3:GetObjectVersionAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts",
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts/*"
      ]
    },
%{ endif }
    {
      "Sid": "DfiS3GetPolicy",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts/*",
        "arn:aws:s3:::${region}-${environment_name}-dfi-extracts"
      ],
      "Condition": {
        "StringEquals": {
          "s3:ExistingObjectTag/av-status": [
            "infected"
          ]
        }
      }
    }
  ]
}
