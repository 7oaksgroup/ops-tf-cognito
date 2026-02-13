locals {
  # cognito_root_domain = "${var.environment}.${var.prefix}.${var.root_domain}"
  # cognito_pool_domain = "auth.${local.cognito_root_domain}"

  users_config_raw = yamldecode(file(var.users_config_file_path))

  # Expand extra_emails into additional user entries with the same attributes
  users_config_map = merge(
    { for email, user in local.users_config_raw : email => {
      given_name            = user.given_name
      family_name           = user.family_name
      email                 = user.email
      additional_attributes = lookup(user, "additional_attributes", {})
      groups                = user.groups
    } },
    merge([
      for email, user in local.users_config_raw : {
        for extra in lookup(user, "extra_emails", []) : extra => {
          given_name            = user.given_name
          family_name           = user.family_name
          email                 = extra
          additional_attributes = lookup(user, "additional_attributes", {})
          groups                = user.groups
        }
      }
    ]...)
  )
  groups_config_map = yamldecode(file(var.groups_config_file_path))
}
