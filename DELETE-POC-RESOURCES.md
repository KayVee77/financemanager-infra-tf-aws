# 🔍 POC Resources - Final Deletion List

**Status:** ⏳ Awaiting Approval  
**Date:** December 14, 2024  
**Region:** eu-central-1

---

## 📊 SUMMARY

| Category | POC Resources | Terraform Resources |
|----------|---------------|---------------------|
| Lambda Functions | 1 ❌ | 1 ✅ |
| ECS Clusters | 1 ❌ | 1 ✅ |
| ECS Services | 1 ❌ | 1 ✅ |
| DynamoDB Tables | 2 ❌ | 2 ✅ |
| Cognito Pools | 1 ❌ | 1 ✅ |
| ECR Repositories | 1 ❌ | 1 ✅ |
| CloudFront | 1 ❌ | 1 ✅ |
| ALB | 1 ❌ | 1 ✅ |
| Target Groups | 2 ❌ | 1 ✅ |
| API Gateway | 1 ❌ | 1 ✅ |
| CloudWatch Logs | 2 ❌ | 2 ✅ |
| VPC | 1 ⚠️ (default) | 1 ✅ |
| **TOTAL TO DELETE** | **15 resources** | **Keep all TF** |

---

## ❌ RESOURCES TO DELETE

### 1. Lambda Functions
```
❌ financeflow-openai-poc (eu-central-1)
```

### 2. ECS Resources
```
❌ Cluster: financeflow-cluster-poc1
   └─ Service: financeflow-service-poc (must delete first)
```

### 3. DynamoDB Tables
```
❌ financeflow-categories-poc
❌ financeflow-transactions-poc
```
⚠️ **Warning:** POC data will be permanently lost!

### 4. Cognito User Pool
```
❌ User pool - vgnmwt (eu-central-1_kaKX5BNfr)
```

### 5. ECR Repository
```
❌ financeflow-unified-poc
```

### 6. CloudFront Distribution
```
❌ E3RZUPXUHBSZ09 (Origin: financeflow-alb-poc)
```
⚠️ **Note:** Must disable first (15min wait), then delete

### 7. Application Load Balancer
```
❌ financeflow-alb-poc
   DNS: financeflow-alb-poc-675179177.eu-central-1.elb.amazonaws.com
   VPC: vpc-0ea8b02788bd1bc4e
```

### 8. Target Groups
```
❌ financeflow-tg-poc (vpc-0ea8b02788bd1bc4e)
❌ financeflow-tg-poc-8080 (vpc-0ea8b02788bd1bc4e)
```

### 9. API Gateway
```
❌ financeflow-ai-api-poc (win2elwu22, HTTP)
```

### 10. CloudWatch Log Groups
```
❌ /ecs/financeflow-task-poc
❌ /aws/ecs/containerinsights/financeflow-cluster-poc1/performance
```

### 11. VPC
```
⚠️ vpc-0ea8b02788bd1bc4e (172.31.0.0/16)
```
⚠️ **DO NOT DELETE** - This is AWS default VPC

---

## ✅ TERRAFORM RESOURCES (KEEP)

### Protected Resources - Managed by Terraform

```
✅ Lambda: tf_financeflow-prod-openai
✅ ECS Cluster: tf_financeflow-prod-cluster
✅ ECS Service: tf_financeflow-prod-service
✅ DynamoDB: tf_financeflow-prod-transactions
✅ DynamoDB: tf_financeflow-prod-categories
✅ Cognito: tf_financeflow-prod-user-pool (eu-central-1_RDCXJdN99)
✅ ECR: tf_financeflow-prod-app
✅ CloudFront: E3PP1MOY6GDLTE
✅ ALB: tf-financeflow-prod-alb
✅ Target Group: tf-financeflow-prod-tg
✅ API Gateway: tf_financeflow-prod-ai-api (vdhz0btyi5)
✅ VPC: vpc-0112a74c292fa434d (10.10.0.0/16)
✅ CloudWatch: /ecs/tf_financeflow-prod
✅ CloudWatch: /aws/lambda/tf_financeflow-prod-openai
✅ 7× Resource Groups
✅ All networking in vpc-0112a74c292fa434d
```

---

## 🔄 DELETION ORDER

Execute in this specific order to avoid dependency errors:

### Phase 1: Disable CloudFront
```powershell
# 1. Get CloudFront config
aws cloudfront get-distribution-config --id E3RZUPXUHBSZ09 --query 'DistributionConfig' --output json > cf-config.json

# 2. Disable (edit JSON: set Enabled=false)
aws cloudfront update-distribution --id E3RZUPXUHBSZ09 --if-match <ETag> --distribution-config file://cf-config.json

# 3. Wait 15-20 minutes for status to become "Deployed"
```

### Phase 2: ECS Resources (Stop Services First)
```powershell
# 4. Stop ECS Service
aws ecs update-service --cluster financeflow-cluster-poc1 --service financeflow-service-poc --desired-count 0 --region eu-central-1

# 5. Delete ECS Service
aws ecs delete-service --cluster financeflow-cluster-poc1 --service financeflow-service-poc --force --region eu-central-1

# 6. Delete ECS Cluster
aws ecs delete-cluster --cluster financeflow-cluster-poc1 --region eu-central-1
```

### Phase 3: Load Balancing
```powershell
# 7. Delete ALB
aws elbv2 delete-load-balancer --load-balancer-arn $(aws elbv2 describe-load-balancers --names financeflow-alb-poc --region eu-central-1 --query 'LoadBalancers[0].LoadBalancerArn' --output text) --region eu-central-1

# 8. Wait 2-3 minutes, then delete Target Groups
aws elbv2 delete-target-group --target-group-arn $(aws elbv2 describe-target-groups --names financeflow-tg-poc --region eu-central-1 --query 'TargetGroups[0].TargetGroupArn' --output text) --region eu-central-1

aws elbv2 delete-target-group --target-group-arn $(aws elbv2 describe-target-groups --names financeflow-tg-poc-8080 --region eu-central-1 --query 'TargetGroups[0].TargetGroupArn' --output text) --region eu-central-1
```

### Phase 4: API & Lambda
```powershell
# 9. Delete API Gateway
aws apigatewayv2 delete-api --api-id win2elwu22 --region eu-central-1

# 10. Delete Lambda Function
aws lambda delete-function --function-name financeflow-openai-poc --region eu-central-1
```

### Phase 5: Data & Auth
```powershell
# 11. Delete DynamoDB Tables (⚠️ DATA LOSS!)
aws dynamodb delete-table --table-name financeflow-categories-poc --region eu-central-1
aws dynamodb delete-table --table-name financeflow-transactions-poc --region eu-central-1

# 12. Delete Cognito User Pool
aws cognito-idp delete-user-pool --user-pool-id eu-central-1_kaKX5BNfr --region eu-central-1
```

### Phase 6: Container Registry
```powershell
# 13. Delete ECR images (if any)
aws ecr batch-delete-image --repository-name financeflow-unified-poc --image-ids "$(aws ecr list-images --repository-name financeflow-unified-poc --region eu-central-1 --query 'imageIds[*]' --output json)" --region eu-central-1

# 14. Delete ECR Repository
aws ecr delete-repository --repository-name financeflow-unified-poc --force --region eu-central-1
```

### Phase 7: CloudFront (After Disabled)
```powershell
# 15. Delete CloudFront Distribution (after 15min disable wait)
aws cloudfront delete-distribution --id E3RZUPXUHBSZ09 --if-match <ETag>
```

### Phase 8: Cleanup
```powershell
# 16. Delete CloudWatch Log Groups
aws logs delete-log-group --log-group-name /ecs/financeflow-task-poc --region eu-central-1
aws logs delete-log-group --log-group-name /aws/ecs/containerinsights/financeflow-cluster-poc1/performance --region eu-central-1
```

---

## 🛡️ SAFETY CHECKS

Before deletion, verify:

### Check for running ECS tasks:
```powershell
aws ecs list-tasks --cluster financeflow-cluster-poc1 --region eu-central-1
```

### Check for Cognito users:
```powershell
aws cognito-idp list-users --user-pool-id eu-central-1_kaKX5BNfr --region eu-central-1 --query 'Users[].Username'
```

### Check DynamoDB item count:
```powershell
aws dynamodb describe-table --table-name financeflow-transactions-poc --region eu-central-1 --query 'Table.ItemCount'
aws dynamodb describe-table --table-name financeflow-categories-poc --region eu-central-1 --query 'Table.ItemCount'
```

### Check ECR images:
```powershell
aws ecr list-images --repository-name financeflow-unified-poc --region eu-central-1
```

---

## 💰 COST SAVINGS (Estimated Monthly)

| Resource | Savings |
|----------|---------|
| ECS Service (if running) | ~$10-30 |
| ALB | ~$16 |
| NAT Gateway (if exists) | ~$32 |
| CloudFront | Variable (data transfer) |
| DynamoDB | ~$1-5 (minimal) |
| **TOTAL ESTIMATED** | **~$60-85/month** |

---

## 📝 NEXT STEPS

1. **Review this list** ✅ (peržiūrėk)
2. **Confirm deletion** ⏳ (patvirtink kad galiu trinti)
3. **Execute commands** ⏳ (vykdysiu komandas)
4. **Verify cleanup** ⏳ (patikrinsiu kad viskas ištrinta)

---

## ⚠️ WARNINGS

- ❌ **Default VPC**: Will **NOT** be deleted (vpc-0ea8b02788bd1bc4e)
- ❌ **Data Loss**: DynamoDB POC data will be permanently lost
- ⏰ **Time**: CloudFront deletion requires 15-20 minute wait
- 🔗 **Dependencies**: Resources must be deleted in order shown above

---

**Ready for deletion? Confirm and I'll execute the cleanup!**
