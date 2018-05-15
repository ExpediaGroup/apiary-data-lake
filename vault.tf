/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

provider "vault" {
  address         = "${var.vault_addr}"
  skip_tls_verify = "true"
}
