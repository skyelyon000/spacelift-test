# =============================================================================
# policies/plan-policy.rego
#
# Example Spacelift Plan Policy:
#   - Warn whenever an IAM resource is being created or modified
#   - Require approval before any IAM role is created
#
# Attach this policy to your stack in the Spacelift UI under Policies.
# =============================================================================

package spacelift

# Auto-approve runs that only touch "safe" resource types
approve {
  no_iam_changes
}

# Warn (but still allow) when IAM resources are touched
warn["IAM resources are being modified — please review carefully"] {
  iam_change
}

# Block + require human approval when an IAM role is being CREATED
deny["Creating IAM roles requires explicit approval — set create_iam_role=false to skip"] {
  some resource in input.terraform.resource_changes
  resource.type == "aws_iam_role"
  resource.change.actions[_] == "create"
}

# ------ helpers ------

iam_change {
  some resource in input.terraform.resource_changes
  startswith(resource.type, "aws_iam_")
  resource.change.actions[_] != "no-op"
}

no_iam_changes {
  not iam_change
}
