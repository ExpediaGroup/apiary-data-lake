/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "sns_for_hms_readwrite" {
  count = "${var.enable_metadata_events == "" ? 0 : 1}"
  name  = "sns"
  role  = "${aws_iam_role.apiary_hms_readwrite.id}"

  policy = <<EOF
{
   "Version" : "2012-10-17",
   "Statement" :
   [
     {
       "Effect" : "Allow",
       "Action" : ["SNS:Publish"],
       "Resource" : ["${aws_sns_topic.apiary_metadata_events.arn}"]
     }
   ]
}
EOF
}
