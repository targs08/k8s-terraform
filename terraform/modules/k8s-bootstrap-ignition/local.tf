locals {
  // Mapping variables for afterburn
  // https://github.com/coreos/afterburn/blob/master/docs/usage/attributes.md
  afterburn = {
    "aws" = {
      HOSTNAME = "$${AFTERBURN_AWS_HOSTNAME}"
      PRIVATE_IPV4 = "$${AFTERBURN_AWS_IPV4_LOCAL}"
      PUBLIC_IPV4 = "$${AFTERBURN_AWS_IPV4_PUBLIC}"
    }
    "custom" = {
      HOSTNAME = "$${AFTERBURN_CUSTOM_HOSTNAME}"
      PRIVATE_IPV4 = "$${AFTERBURN_CUSTOM_PRIVATE_IPV4}"
      PUBLIC_IPV4 = "$${AFTERBURN_CUSTOM_PUBLIC_IPV4}"
    }
  }
}