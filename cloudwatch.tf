/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "s3_widgets" {
  count = "${length(var.apiary_data_buckets)}"

  template = <<EOF
       {
          "type":"metric",
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/S3",
                   "BucketSizeBytes",
                   "StorageType",
                   "StandardStorage",
                   "BucketName",
                   "$${bucket_name}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary S3 Usage($${bucket_name})"
          }
       },
       {
          "type":"metric",
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/S3",
                   "NumberOfObjects",
                   "StorageType",
                   "AllStorageTypes",
                   "BucketName",
                   "$${bucket_name}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary No of Objects($${bucket_name})"
          }
       },
       {
           "type": "metric",
           "width": 12,
           "height": 6,
           "properties": {
               "view": "timeSeries",
               "stacked": false,
               "region": "us-west-2",
               "metrics": [
                    [ "AWS/S3", "AllRequests", "FilterId", "EntireBucket", "BucketName", "$${bucket_name}" ],
                    [ "AWS/S3", "GetRequests", "FilterId", "EntireBucket", "BucketName", "$${bucket_name}" ],
                    [ "AWS/S3", "PutRequests", "FilterId", "EntireBucket", "BucketName", "$${bucket_name}" ]
               ],
               "period": 300,
               "region":"${var.aws_region}",
               "title":"Apiary S3 Requests($${bucket_name})"
           }
       },
       {
           "type": "metric",
           "width": 12,
           "height": 6,
           "properties": {
               "view": "timeSeries",
               "stacked": false,
               "metrics": [
                    [ "AWS/S3", "BytesDownloaded", "FilterId", "EntireBucket", "BucketName", "$${bucket_name}" ],
                    [ "AWS/S3", "BytesUploaded", "FilterId", "EntireBucket", "BucketName", "$${bucket_name}" ]
               ],
               "period": 300,
               "region":"${var.aws_region}",
               "title":"Apiary S3 Data Transfer($${bucket_name})"
           }
       },
EOF

  vars {
    bucket_name = "${var.apiary_data_buckets[count.index]}"
  }
}

resource "aws_cloudwatch_dashboard" "apiary" {
  dashboard_name = "${local.instance_alias}-${var.aws_region}"

  dashboard_body = <<EOF
 {
   "widgets": [
${join("", data.template_file.s3_widgets.*.rendered)}
       {
          "type":"metric",
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/RDS",
                   "CPUUtilization",
                   "DBClusterIdentifier",
                   "${aws_rds_cluster.apiary_cluster.id}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary DB CPU"
          }
       },
       {
          "type":"metric",
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/ECS",
                   "CPUUtilization",
                   "ClusterName",
                   "apiary"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary ECS CPU Utilization"
          }
       },
       {
          "type":"metric",
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/ECS",
                   "MemoryUtilization",
                   "ClusterName",
                   "apiary"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary ECS Memory Utilization"
          }
       },
       {
          "type":"metric",
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/NetworkELB",
                   "NetFlowCount",
                   "LoadBalancer",
                   "${aws_lb.apiary_hms_readwrite_lb.arn_suffix}"
                ],
                [
                   "AWS/NetworkELB",
                   "NetFlowCount",
                   "LoadBalancer",
                   "${aws_lb.apiary_hms_readonly_lb.arn_suffix}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary ELB Request Count"
          }
       },
       {
          "type":"metric",
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/NetworkELB",
                   "ProcessedBytes",
                   "LoadBalancer",
                   "${aws_lb.apiary_hms_readwrite_lb.arn_suffix}"
                ],
                [
                   "AWS/NetworkELB",
                   "ProcessedBytes",
                   "LoadBalancer",
                   "${aws_lb.apiary_hms_readonly_lb.arn_suffix}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary ELB Processed Bytes"
          }
       }
   ]
 }
 EOF
}

locals {
  alerts = [
    {
      alarm_name  = "${local.instance_alias}-hms-readwrite-cpu"
      namespace   = "AWS/ECS"
      metric_name = "CPUUtilization"
      threshold   = "80"
    },
    {
      alarm_name  = "${local.instance_alias}-hms-readonly-cpu"
      namespace   = "AWS/ECS"
      metric_name = "CPUUtilization"
      threshold   = "80"
    },
    {
      alarm_name  = "${local.instance_alias}-hms-readwrite-memory"
      namespace   = "AWS/ECS"
      metric_name = "MemoryUtilization"
      threshold   = "70"
    },
    {
      alarm_name  = "${local.instance_alias}-hms-readonly-memory"
      namespace   = "AWS/ECS"
      metric_name = "MemoryUtilization"
      threshold   = "70"
    },
    {
      alarm_name  = "${local.instance_alias}-db-cpu"
      namespace   = "AWS/RDS"
      metric_name = "CPUUtilization"
      threshold   = "70"
    },
  ]

  dimensions = [
    {
      ClusterName = "${aws_ecs_cluster.apiary.name}"
      ServiceName = "${aws_ecs_cluster.apiary.name}-hms-readwrite-service"
    },
    {
      ClusterName = "${aws_ecs_cluster.apiary.name}"
      ServiceName = "${aws_ecs_cluster.apiary.name}-hms-readonly-service"
    },
    {
      ClusterName = "${aws_ecs_cluster.apiary.name}"
      ServiceName = "${aws_ecs_cluster.apiary.name}-hms-readwrite-service"
    },
    {
      ClusterName = "${aws_ecs_cluster.apiary.name}"
      ServiceName = "${aws_ecs_cluster.apiary.name}-hms-readonly-service"
    },
    {
      DBClusterIdentifier = "${aws_rds_cluster.apiary_cluster.id}"
    },
  ]
}

resource "aws_cloudwatch_metric_alarm" "apiary_alert" {
  count               = "${length(local.alerts)}"
  alarm_name          = "${lookup(local.alerts[count.index],"alarm_name")}"
  comparison_operator = "${lookup(local.alerts[count.index],"comparison_operator","GreaterThanOrEqualToThreshold")}"
  metric_name         = "${lookup(local.alerts[count.index],"metric_name")}"
  namespace           = "${lookup(local.alerts[count.index],"namespace")}"
  period              = "${lookup(local.alerts[count.index],"period","120")}"
  evaluation_periods  = "${lookup(local.alerts[count.index],"evaluation_periods","2")}"
  statistic           = "Average"
  threshold           = "${lookup(local.alerts[count.index],"threshold")}"

  #alarm_description         = "This metric monitors apiary ecs ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions                = "${local.dimensions[count.index]}"
  alarm_actions             = ["${aws_sns_topic.apiary_ops_sns.arn}"]
}
