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
        Sid: "Enable IAM User Permissions",
        Effect: "Allow",
        Principal: {
          AWS: [
            "arn:aws:iam::975732635630:root",
          ]
        },
        Action: "kms:*",
        Resource: "*"
      },
      {
        Sid: "Enable EBS Encryption",
        Effect: "Allow",
        Principal: {
          Service: "ec2.amazonaws.com"
        },
        Action: "kms:Encrypt",
        Resource: "*"
      },
      {
        Sid: "Allow Key Rotation",
        Effect: "Allow",
        Principal: {
          Service: "ec2.amazonaws.com"
        },
        Action: "kms:Rotate*",
        Resource: "*"
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
