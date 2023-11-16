resource "aws_kms_key" "cmk" {
  description             = "CMK to encrypt EBS volumes"
  key_usage               = "ENCRYPT_DECRYPT"
  is_enabled              = true
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version: "2012-10-17",
    Id: "gc-ebs-policy",
    Statement: [
    {
    "Version": "2012-10-17",
    "Id": "gc-ebs-policy",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::148285078518:root",
                    "arn:aws:iam::625109008004:root"
                ]
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::625109008004:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
                    "arn:aws:iam::625109008004:role/gc-eks-service-role-production-k8s-role"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::625109008004:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
                    "arn:aws:iam::625109008004:role/gc-eks-service-role-production-k8s-role",
                    "arn:aws:iam::148285078518:root"
                ]
            },
            "Action": "kms:CreateGrant",
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
    ]
  })
}

resource "aws_kms_alias" "cmk_alias" {
  name          = "alias/gc/ebs_new"
  target_key_id = aws_kms_key.cmk.key_id
}

output "cmk_id" {
  value = aws_kms_key.cmk.id
}


