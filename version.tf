/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

terraform {
  required_version = "> 0.12.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    datadog = {
      source = "DataDog/datadog"
      version = "3.25.0"
    }
  }
}
