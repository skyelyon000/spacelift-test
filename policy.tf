package spacelift

# Distinguish between PR runs and tracked branch runs
proposed := input.spacelift.run.type == "PROPOSED"

# ─── HARD BLOCK ───────────────────────────────────────────────────────────────
# Never allow static AWS IAM access keys to be created
deny contains sprintf("static AWS credentials are dangerous (%s)", [resource.address]) if {
  some resource in input.terraform.resource_changes
  some action in resource.change.actions
  action == "create"
  resource.type == "aws_iam_access_key"
}

# ─── SMART WARN / DENY ────────────────────────────────────────────────────────
# Deny on PRs, warn on tracked branch — for IAM user creation
deny contains reason if { proposed; some reason in iam_user_created }
warn contains reason if { not proposed; some reason in iam_user_created }

iam_user_created contains sprintf("avoid creating IAM users, use roles instead (%s)", [resource.address]) if {
  some resource in input.terraform.resource_changes
  some action in resource.change.actions
  action == "create"
  resource.type == "aws_iam_user"
}

# ─── HUMAN REVIEW ─────────────────────────────────────────────────────────────
# Flag any delete or update for human review (won't block, but pauses autodeploy)
warn contains sprintf("action '%s' requires human review (%s)", [action, resource.address]) if {
  review := {"update", "delete"}
  some resource in input.terraform.resource_changes
  some action in resource.change.actions
  review[action]
}
