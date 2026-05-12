# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

############################
# Storage Configuration    #
############################

# tflint-ignore: terraform_unused_declarations
variable "app_storage_account_name" {
  description = "Name of an existing storage account to use with the app service"
  type        = string
  default     = null
}

variable "existing_storage_private_dns_zone" {
  description = "Name of an existing private DNS zone to use with the storage account"
  type        = string
  default     = null
}
