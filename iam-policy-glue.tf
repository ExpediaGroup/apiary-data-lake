/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

 resource "aws_iam_role_policy" "glue_for_ecs_task_readwrite" {
   count = "${ var.enable_gluesync == "" ? 0 : 1 }"
   name  = "glue"
   role  = "${aws_iam_role.apiary_task_readwrite.id}"

   policy = <<EOF
{
   "Version" : "2012-10-17",
   "Statement" :
   [
     {
       "Effect" : "Allow",
       "Action" : ["glue:*"],
       "Resource" : ["*"]
     }
   ]
}
EOF
 }
