resource "null_resource" "automatic_glue_stats_collector_script" {
  count        = var.enable_glue_stats ? 1 : 0

  triggers = {
    account_id = data.aws_caller_identity.current.account_id
    region     = var.aws_region
    role_arn   = aws_iam_role.glue_stats_service_role[0].arn
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/enable-glue-stats.sh"
    environment = {
      ACCOUNT_ID  = data.aws_caller_identity.current.account_id
      ROLE_ARN    = aws_iam_role.glue_service_role[0].arn
    }
  }
}