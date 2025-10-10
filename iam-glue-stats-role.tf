resource "aws_iam_role" "glue_stats_service_role" {
  count = var.enable_glue_stats ? 1 : 0

  name = "glue-stats-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_stats_service_role_policy" {
  count = var.enable_glue_stats ? 1 : 0

  role       = aws_iam_role.glue_stats_service_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_stats_service_role_lf_policy" {
  count = var.enable_glue_stats ? 1 : 0

  role   = aws_iam_role.glue_stats_service_role[0].name
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
       {
            "Sid": "LakeFormationDataAccess",
            "Effect": "Allow",
            "Action": "lakeformation:GetDataAccess",
            "Resource": [
                "*"
            ]
        },
        {
          "Sid": "PassRole",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": [
              "${aws_iam_role.glue_stats_service_role[0].arn}"
          ]
        }
    ]
}
EOF
}