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
      version = ">= 5.17.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    datadog = {
      source  = "datadog/datadog"
      version = "3.25.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}
