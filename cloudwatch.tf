/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_cloudwatch_dashboard" "apiary" {
  dashboard_name = "Apiary"

  dashboard_body = <<EOF
 {
   "widgets": [
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
                   "AWS/S3",
                   "BucketSizeBytes",
                   "StorageType",
                   "StandardStorage",
                   "BucketName",
                   "${var.apiary_data_buckets[0]}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary S3 Usage"
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
                   "${var.apiary_data_buckets[0]}"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"${var.aws_region}",
             "title":"Apiary No of Objects"
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
                    [ "AWS/S3", "AllRequests", "FilterId", "EntireBucket", "BucketName", "${var.apiary_data_buckets[0]}" ],
                    [ "AWS/S3", "GetRequests", "FilterId", "EntireBucket", "BucketName", "${var.apiary_data_buckets[0]}" ],
                    [ "AWS/S3", "PutRequests", "FilterId", "EntireBucket", "BucketName", "${var.apiary_data_buckets[0]}" ]
               ],
               "period": 300,
               "region":"${var.aws_region}"
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
                    [ "AWS/S3", "BytesDownloaded", "FilterId", "EntireBucket", "BucketName", "${var.apiary_data_buckets[0]}" ],
                    [ "AWS/S3", "BytesUploaded", "FilterId", "EntireBucket", "BucketName", "${var.apiary_data_buckets[0]}" ]
               ],
               "period": 300,
               "region":"${var.aws_region}"
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
      alarm_name = "apiary-ecs-cpu"

      namespace = "AWS/EC2"

      metric_name = "CPUUtilization"

      threshold = "80"
    },
    {
      alarm_name = "apiary-ecs-memory"

      namespace = "AWS/ECS"

      metric_name = "MemoryUtilization"

      threshold = "70"
    },
    {
      alarm_name = "apiary-db-cpu"

      namespace = "AWS/RDS"

      metric_name = "CPUUtilization"

      threshold = "70"
    },
    {
      alarm_name = "apiary-s3-usage"

      namespace = "AWS/S3"

      metric_name = "BucketSizeBytes"

      threshold = "${var.apiary_s3_alarm_threshold}"

      period = "86400"

      evaluation_periods = "1"
    },
  ]

  dimensions = [
    {
      AutoScalingGroupName = "${aws_autoscaling_group.ecs_cluster.name}"
    },
    {
      ClusterName = "${aws_ecs_cluster.apiary.name}"
    },
    {
      DBClusterIdentifier = "${aws_rds_cluster.apiary_cluster.id}"
    },
    {
      StorageType = "StandardStorage"

      BucketName = "${var.apiary_data_buckets[0]}"
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
