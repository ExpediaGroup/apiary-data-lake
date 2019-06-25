
resource "aws_iam_instance_profile" "apiary_task_readwrite" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name  = "${local.instance_alias}-ecs-task-readwrite-${var.aws_region}"
  role  = "${aws_iam_role.apiary_task_readwrite.name}"
}

resource "aws_iam_instance_profile" "apiary_task_readonly" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name  = "${local.instance_alias}-ecs-task-readonly-${var.aws_region}"
  role  = "${aws_iam_role.apiary_task_readonly.name}"
}
