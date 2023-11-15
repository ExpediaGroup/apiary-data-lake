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
      version = "~> 2.7.0"
    }
    aws = {
      source  = "hashicorp/aws"
      aws     = "~> 4.0"
    }
  }
}
