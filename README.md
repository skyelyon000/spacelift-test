## What's in here

| File | Purpose |
|------|---------|
| `main.tf` | S3 bucket, SSM parameter, optional IAM role |
| `variables.tf` | All the knobs you can turn |
| `outputs.tf` | Useful values surfaced after `apply` |
| `example.tfvars` | Copy → `terraform.tfvars` for local runs |
| `spacelift.tf` | Commented-out stack-as-code definition |
| `policies/plan-policy.rego` | Example plan policy (warns + blocks IAM creates) |
