resource "aws_iam_role" "hive_db_updater_lambda" {
  name = "${local.instance_alias}-hive-db-updater-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
 EOF
}

resource "aws_iam_role_policy" "secretsmanager_for_lambda" {
  name = "secretsmanager"
  role = "${aws_iam_role.hive_db_updater_lambda.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "${data.aws_secretsmanager_secret.db_rw_user.arn}"
    }
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_for_lambda" {
  role       = "${aws_iam_role.hive_db_updater_lambda.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "null_resource" "pip" {
  triggers {
    main         = "${base64sha256(file("${path.module}/scripts/lambda/hive_db_updater.py"))}"
    requirements = "${base64sha256(file("${path.module}/scripts/lambda/requirements.txt"))}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/pip.sh ${path.module} ${path.module}/scripts/lambda/requirements.txt ${path.module}/scripts/lambda/hive_db_updater.py"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/archive"
  output_path = "${path.module}/lambda.zip"

  depends_on = ["null_resource.pip"]
}

resource "aws_lambda_function" "hive_db_updater" {
  filename         = "${data.archive_file.lambda.output_path}"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  function_name    = "${local.instance_alias}-hive-db-updater"
  role             = "${aws_iam_role.hive_db_updater_lambda.arn}"
  description      = "Hive DB updater for ${local.instance_alias}"
  handler          = "hive_db_updater.lambda_handler"
  timeout          = "300"
  runtime          = "python2.7"

  vpc_config {
    subnet_ids         = ["${var.private_subnets}"]
    security_group_ids = ["${aws_security_group.hms_sg.id}"]
  }

  environment {
    variables = {
      mysql_db_host       = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host}"
      mysql_db_name       = "${var.apiary_database_name}"
      mysql_secret_arn    = "${data.aws_secretsmanager_secret.db_rw_user.arn}"
      managed_schemas     = "${join(",", local.apiary_managed_schema_names_original)}"
      apiary_data_buckets = "${join(",", local.apiary_data_buckets)}"
      region              = "${var.aws_region}"
    }
  }

  depends_on = ["data.archive_file.lambda"]
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 90"
  }
}

data "aws_lambda_invocation" "hive_db_updater" {
  function_name = "${aws_lambda_function.hive_db_updater.function_name}"
  input         = ""
  depends_on    = ["aws_lambda_function.hive_db_updater", "null_resource.delay"]
}
