/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sns_topic" "apiary_ops_sns" {
  name = "${local.instance_alias}-operational-events"
}

resource "aws_sns_topic" "apiary_metadata_updates" {
  name = "${local.instance_alias}-metadata-updates"
}
