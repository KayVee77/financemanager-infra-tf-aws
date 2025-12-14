# POC Resources to Delete

**Created:** December 14, 2024
**Region:** eu-central-1

## Summary

Terraform-managed resources: ✅ **Keep** (prefixed with `tf_`)
POC/Manual resources: ❌ **Delete** (no terraform state)

---

## Resources to DELETE (POC/Manual)

### 🔴 Lambda Functions (1)
| Function Name | Region | Status | Notes |
|---------------|--------|--------|-------|
| `financeflow-openai-poc` | eu-central-1 | ❌ DELETE | POC Lambda function |

**Terraform manages:** `tf_financeflow-prod-openai` ✅

---

### 🔴 ECS Clusters (1)
| Cluster Name | ARN | Status |
|--------------|-----|--------|
| `financeflow-cluster-poc1` | `arn:aws:ecs:eu-central-1:703524245589:cluster/financeflow-cluster-poc1` | ❌ DELETE |

**Notes:** Check if cluster has running services before deletion.

**Terraform manages:** `tf_financeflow-prod-cluster` ✅

---

### 🔴 DynamoDB Tables (2)
| Table Name | Status | Data Impact |
|------------|--------|-------------|
| `financeflow-categories-poc` | ❌ DELETE | POC data will be lost |
| `financeflow-transactions-poc` | ❌ DELETE | POC data will be lost |

**Terraform manages:** 
- `tf_financeflow-prod-categories` ✅
- `tf_financeflow-prod-transactions` ✅

---

### 🔴 Cognito User Pools (1)
| User Pool Name | Pool ID | Status | Users |
|----------------|---------|--------|-------|
| `User pool - vgnmwt` | `eu-central-1_kaKX5BNfr` | ❌ DELETE | Check if has users |

**Terraform manages:** `tf_financeflow-prod-user-pool` (eu-central-1_RDCXJdN99) ✅

---

### 🔴 VPCs (1)
| VPC ID | CIDR | Name | Status |
|--------|------|------|--------|
| `vpc-0ea8b02788bd1bc4e` | `172.31.0.0/16` | (default VPC) | ⚠️ SKIP (AWS default) |

**Note:** This is the AWS default VPC - **DO NOT DELETE**

**Terraform manages:** `vpc-0112a74c292fa434d` (10.10.0.0/16) ✅

---

### 🔴 ECR Repositories (1)
| Repository Name | Created | Status | Images |
|-----------------|---------|--------|--------|
| `financeflow-unified-poc` | 2025-11-26 | ❌ DELETE | Check for images |

**Terraform manages:** `tf_financeflow-prod-app` ✅

---

### 🔴 CloudFront Distributions (1)
| Distribution ID | Origin | Comment | Status |
|----------------|---------|---------|--------|
| `E3RZUPXUHBSZ09` | financeflow-alb-poc-675179177.eu-central-1.elb.amazonaws.com | FinanceFlow thesis app with HTTPS | ❌ DELETE |

**Terraform manages:** `E3PP1MOY6GDLTE` (tf-financeflow-prod-alb) ✅

**Note:** CloudFront deletion requires distribution to be disabled first (takes ~15 minutes).

---

### 🔴 Application Load Balancers (1)
| ALB Name | DNS Name | VPC | Status |
|----------|----------|-----|--------|
| `financeflow-alb-poc` | financeflow-alb-poc-675179177.eu-central-1.elb.amazonaws.com | vpc-0ea8b02788bd1bc4e | ❌ DELETE |

**Terraform manages:** `tf-financeflow-prod-alb` ✅

**Note:** This ALB is likely in the default VPC and connected to POC ECS cluster.

---

### 🔴 API Gateway (1)
| API Name | API ID | Protocol | Status |
|----------|--------|----------|--------|
| `financeflow-ai-api-poc` | `win2elwu22` | HTTP | ❌ DELETE |

**Terraform manages:** `tf_financeflow-prod-ai-api` (vdhz0btyi5) ✅

---

## Additional Resources to Check

These resources are likely associated with POC infrastructure and should be deleted:

### Target Groups
- Check for target groups associated with `financeflow-alb-poc`

### Security Groups
- Check for security groups in VPC `vpc-0ea8b02788bd1bc4e` (except default)

### ECS Services
- Check `financeflow-cluster-poc1` for running services

### ECS Task Definitions
- POC task definitions (check for `financeflow` without `tf_` prefix)

### CloudWatch Log Groups
- `/aws/lambda/financeflow-openai-poc`
- `/ecs/financeflow-poc*`

### IAM Roles
- Roles created for POC (check description/tags)

### Subnets
- Subnets in VPC `vpc-0ea8b02788bd1bc4e` (except default ones)

### Internet Gateway / NAT Gateway
- Associated with POC VPC

---

## Deletion Order (Recommended)

To avoid dependency errors, delete in this order:

1. **CloudFront Distribution** (disable first, wait 15min, then delete)
2. **ECS Services** (stop tasks in `financeflow-cluster-poc1`)
3. **ECS Cluster** (`financeflow-cluster-poc1`)
4. **Application Load Balancer** (`financeflow-alb-poc`)
5. **Target Groups** (associated with POC ALB)
6. **API Gateway** (`financeflow-ai-api-poc`)
7. **Lambda Function** (`financeflow-openai-poc`)
8. **DynamoDB Tables** (POC tables - data will be lost!)
9. **Cognito User Pool** (`User pool - vgnmwt`)
10. **ECR Repository** (`financeflow-unified-poc`)
11. **NAT Gateway** (if in POC VPC)
12. **Internet Gateway** (if in POC VPC)
13. **Subnets** (in POC VPC)
14. **Security Groups** (in POC VPC, non-default)
15. **VPC** (POC VPC - only after all resources removed)
16. **Elastic IPs** (if any unassociated)
17. **CloudWatch Log Groups** (POC-related)
18. **IAM Roles** (POC-related, check last)

---

## Terraform-Managed Resources (KEEP)

✅ **These are managed by Terraform - DO NOT DELETE:**

- Lambda: `tf_financeflow-prod-openai`
- ECS Cluster: `tf_financeflow-prod-cluster`
- ECS Service: `tf_financeflow-prod-service`
- DynamoDB: `tf_financeflow-prod-transactions`, `tf_financeflow-prod-categories`
- Cognito: `tf_financeflow-prod-user-pool` (eu-central-1_RDCXJdN99)
- VPC: `vpc-0112a74c292fa434d` (10.10.0.0/16)
- ECR: `tf_financeflow-prod-app`
- CloudFront: `E3PP1MOY6GDLTE`
- ALB: `tf-financeflow-prod-alb`
- API Gateway: `tf_financeflow-prod-ai-api` (vdhz0btyi5)
- 7× Resource Groups
- All networking resources in VPC `vpc-0112a74c292fa434d`

---

## Verification Commands

Before deletion, get detailed info:

```powershell
# Check ECS services in POC cluster
aws ecs list-services --cluster financeflow-cluster-poc1 --region eu-central-1

# Check CloudFront status
aws cloudfront get-distribution --id E3RZUPXUHBSZ09 --query 'Distribution.Status'

# Check ECR images
aws ecr list-images --repository-name financeflow-unified-poc --region eu-central-1

# Check Cognito users
aws cognito-idp list-users --user-pool-id eu-central-1_kaKX5BNfr --region eu-central-1

# Check ALB target groups
aws elbv2 describe-target-groups --load-balancer-arn $(aws elbv2 describe-load-balancers --names financeflow-alb-poc --region eu-central-1 --query 'LoadBalancers[0].LoadBalancerArn' --output text) --region eu-central-1

# Check VPC dependencies
aws ec2 describe-vpcs --vpc-ids vpc-0ea8b02788bd1bc4e --region eu-central-1
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0ea8b02788bd1bc4e" --region eu-central-1
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-0ea8b02788bd1bc4e" --region eu-central-1
```

---

## Cost Impact

Deleting these POC resources will reduce monthly AWS costs. Main savings:

- **NAT Gateway**: ~$32/month (if exists in POC VPC)
- **ALB**: ~$16/month
- **CloudFront**: Data transfer costs
- **ECS**: Running task costs
- **DynamoDB**: Storage costs (minimal)

---

## Next Steps

1. ✅ Review this list
2. ⏳ Run detailed verification commands
3. ⏳ Backup any POC data if needed
4. ⏳ Execute deletion commands (provided after approval)
