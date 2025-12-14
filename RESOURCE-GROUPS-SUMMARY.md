# AWS Resource Groups - Summary

Created: December 14, 2024
Status: ✅ All 7 groups deployed successfully

## Resource Group Statistics

| Group Name | Resources | Description |
|------------|-----------|-------------|
| `financeflow-terraform-resources` | **36** | All Terraform-managed resources |
| `financeflow-terraform-compute` | **5** | ECS and Lambda compute resources |
| `financeflow-terraform-network` | **13** | VPC, subnets, security groups, gateways |
| `financeflow-terraform-database` | **2** | DynamoDB tables |
| `financeflow-terraform-security` | **1** | Cognito User Pool |
| `financeflow-terraform-cdn-lb` | **2** | CloudFront and ALB |
| `financeflow-terraform-prod` | **36** | Production environment resources |

## Detailed Resource Breakdown

### Compute Resources (5)
- 1× Lambda Function (`tf_financeflow-prod-openai`)
- 1× ECS Cluster (`tf_financeflow-prod-cluster`)
- 1× ECS Service (`tf_financeflow-prod-service`)
- 2× ECS Task Definitions (revisions 1 and 2)

### Network Resources (13)
- 1× VPC (`10.10.0.0/16`)
- 6× Subnets (3 public + 3 private across 3 AZs)
- 2× Security Groups (ECS + ALB)
- 1× Internet Gateway
- 1× NAT Gateway
- 2× Route Tables (public + private)

### Database Resources (2)
- `tf_financeflow-prod-transactions` (DynamoDB)
- `tf_financeflow-prod-categories` (DynamoDB)

### Security Resources (1)
- Cognito User Pool (`eu-central-1_RDCXJdN99`)

**Note:** IAM Roles and Policies are **not** included in Resource Groups due to AWS API limitations.

### CDN & Load Balancing (2)
- CloudFront Distribution (`E3PP1MOY6GDLTE`)
- Application Load Balancer (`tf-financeflow-prod-alb`)

## Quick Access Commands

### View All Resources
```powershell
aws resource-groups list-group-resources `
  --group-name financeflow-terraform-resources `
  --region eu-central-1 --output table
```

### Count Resources in Each Group
```powershell
$groups = @(
  'financeflow-terraform-resources',
  'financeflow-terraform-compute',
  'financeflow-terraform-network',
  'financeflow-terraform-database',
  'financeflow-terraform-security',
  'financeflow-terraform-cdn-lb',
  'financeflow-terraform-prod'
)

foreach ($group in $groups) {
  $count = (aws resource-groups list-group-resources `
    --group-name $group --region eu-central-1 `
    --query 'ResourceIdentifiers' --output json | ConvertFrom-Json).Count
  Write-Host "$group : $count resources"
}
```

### Get Console URLs
```bash
terraform output resource_group_console_urls
```

## Console URLs

All resource groups are accessible via AWS Console:

- **All Resources**: https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-resources
- **Compute**: https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-compute
- **Network**: https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-network
- **Database**: https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-database
- **Security**: https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-security
- **CDN & LB**: https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-cdn-lb
- **Production Env**: https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-prod

## Tag Filters Used

All resource groups use tag-based queries:

```json
{
  "ResourceTypeFilters": ["AWS::ECS::*", "AWS::Lambda::*", ...],
  "TagFilters": [
    {
      "Key": "ManagedBy",
      "Values": ["terraform"]
    },
    {
      "Key": "Project",
      "Values": ["financeflow"]
    }
  ]
}
```

Production environment group adds additional filter:
```json
{
  "Key": "Environment",
  "Values": ["prod"]
}
```

## Benefits

1. **Centralized View**: Single place to view all infrastructure resources
2. **Cost Tracking**: Tag-based cost allocation reports
3. **Bulk Operations**: Apply actions across resource groups
4. **Compliance**: Easy audit and compliance reporting
5. **Monitoring**: CloudWatch dashboards per resource group
6. **Team Visibility**: Non-technical stakeholders can view resources

## Terraform Outputs

```bash
$ terraform output resource_groups

{
  "all_resources" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-resources"
  "cdn_lb" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-cdn-lb"
  "compute" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-compute"
  "database" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-database"
  "network" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-network"
  "prod_env" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-prod"
  "security" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-security"
}
```

## Maintenance

Resource groups automatically update as resources are created/destroyed via Terraform. No manual maintenance required.

To verify after infrastructure changes:
```bash
terraform apply
# Wait 1-2 minutes for tag propagation
aws resource-groups list-group-resources --group-name financeflow-terraform-resources
```
