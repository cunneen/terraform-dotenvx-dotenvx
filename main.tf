# Copyright (c) Mike Cunneen
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

locals {
  working_dir = (var.env_folderpath != null && var.env_folderpath != "") ? var.env_folderpath : path.root
}

# Run the dotenvx script to get the environment variables of interest.
# This is a data source, so it will run at plan time.
data "external" "env" {
  working_dir = local.working_dir

  program = concat(["dotenvx", "get", "--format=json"],
    (var.is_nextjs_convention ? ["--convention=nextjs"] : []),
    (var.should_ignore_missing_env_file ? ["--ignore=MISSING_ENV_FILE"] : []),
    ((var.env_filepath != null && var.env_filepath != "") ? ["-f", "${var.env_filepath}"] : []),
  )
}
