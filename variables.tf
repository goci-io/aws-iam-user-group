
variable "stage" {
  type        = string
  description = "The stage the hosted zone will be created for"
}

variable "namespace" {
  type        = string
  description = "Namespace the hosted zone belongs to. Used to determine the root domain if domain_name is not set"
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `eu1`)"
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "additional_statements" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  default     = []
  description = "Attaches additional statements to the policies and allows the permissions if MFA is enabled"
}

variable "users_path" {
  type        = string
  default     = "*"
  description = "A users ARN path matcher to put in place in addition to user/<name>. You can also apply nested paths and wildcards"
}
