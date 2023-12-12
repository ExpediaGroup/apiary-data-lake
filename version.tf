/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

terraform {
  required_version = "~> 0.11"

  required_providers = {
    aws = "~> 1.60.0"
  }
  datadog = {
    source = "DataDog/datadog"
    version = "3.25.0"
  }
}
