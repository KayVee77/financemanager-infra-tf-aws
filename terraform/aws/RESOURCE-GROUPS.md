# Resource Groups Management

## Apžvalga

AWS Resource Groups leidžia organizuoti ir valdyti resursus pagal tags. FinanceFlow infrastruktūrai sukurti 7 resource groups skirtingiems resursų tipams.

## Sukurti Resource Groups

### 1. **financeflow-terraform-resources** (Main Group)
Visi Terraform valdomi resursai su tags:
- `ManagedBy: terraform`
- `Project: financeflow`

**AWS CLI:**
```bash
aws resource-groups get-group --group-name financeflow-terraform-resources
```

**Console URL:**
https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-resources

---

### 2. **financeflow-terraform-compute** (Compute)
ECS ir Lambda resursai:
- ECS Cluster, Service, Task Definition
- Lambda Functions

**Naudojimas:**
```bash
# Sąrašas visų compute resursų
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-compute \
  --query 'Resources[*].[ResourceType, Identifier]' \
  --output table
```

---

### 3. **financeflow-terraform-network** (Network)
VPC ir networking resursai:
- VPC, Subnets, Security Groups
- Internet Gateway, NAT Gateway
- Route Tables

**Naudojimas:**
```bash
# Patikrinti network resources
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-network \
  --output table
```

---

### 4. **financeflow-terraform-database** (Database)
DynamoDB lentelės:
- tf_financeflow-prod-transactions
- tf_financeflow-prod-categories

**Naudojimas:**
```bash
# DynamoDB lentelių sąrašas
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-database
```

---

### 5. **financeflow-terraform-security** (Security)
Saugumo resursai:
- Cognito User Pool
- IAM Roles ir Policies

**Naudojimas:**
```bash
# Security resources
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-security
```

---

### 6. **financeflow-terraform-cdn-lb** (CDN & Load Balancing)
CloudFront ir ALB:
- CloudFront Distribution
- Application Load Balancer
- Target Groups

**Naudojimas:**
```bash
# CDN/LB resources
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-cdn-lb
```

---

### 7. **financeflow-terraform-prod** (Production Environment)
Visi prod aplinkos resursai su tag `Environment: prod`

---

## Naudingos komandos

### Gauti visų resursų sąrašą grupėje
```bash
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-resources \
  --query 'Resources[*].[ResourceType, Identifier]' \
  --output table
```

### Gauti resource group informaciją
```bash
aws resource-groups get-group \
  --group-name financeflow-terraform-resources
```

### Skaičiuoti resursų kiekį grupėje
```bash
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-compute \
  --query 'length(Resources)' \
  --output text
```

### Gauti resource ARN sąrašą
```bash
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-database \
  --query 'Resources[*].Identifier' \
  --output json
```

### Filtruoti pagal resource type
```bash
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-resources \
  --resource-type-filters "AWS::DynamoDB::Table" \
  --output table
```

### Tag-based query visoje account
```bash
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=ManagedBy,Values=terraform Key=Project,Values=financeflow \
  --resource-type-filters "AWS::AllSupported"
```

---

## Cost Tracking

Resource groups gali būti naudojami su AWS Cost Explorer:

### 1. AWS Console
```
Cost Explorer > Filters > Tag > ManagedBy: terraform
```

### 2. AWS CLI (Cost per resource group)
```bash
aws ce get-cost-and-usage \
  --time-period Start=2025-12-01,End=2025-12-14 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --filter file://filter.json
```

**filter.json:**
```json
{
  "Tags": {
    "Key": "ManagedBy",
    "Values": ["terraform"]
  }
}
```

---

## CloudWatch Dashboard Integration

Galima sukurti CloudWatch dashboard su resource group metrikom:

```bash
aws cloudwatch put-dashboard \
  --dashboard-name FinanceFlow-Terraform \
  --dashboard-body file://dashboard.json
```

---

## Terraform Output

Po `terraform apply`, gauti resource group information:

```bash
terraform output resource_groups
terraform output resource_group_console_urls
```

Output pavyzdys:
```hcl
resource_groups = {
  "all_resources" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-resources"
  "compute" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-compute"
  "database" = "arn:aws:resource-groups:eu-central-1:703524245589:group/financeflow-terraform-database"
  ...
}
```

---

## Resource Group Tags

Visi resource groups turi šiuos tags:
- `ManagedBy: terraform`
- `Project: financeflow`
- `Environment: prod`
- `Owner: thesis-student`
- `TerraformPrefix: tf_`

Papildomi tags pagal tipą:
- `ResourceType: Compute/Network/Database/Security/CDN-LB`

---

## Cleanup

Norėdami ištrinti visus Terraform resursus:

```bash
# 1. Gauti visų resursų sąrašą
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-resources \
  --output json > resources.json

# 2. Ištrinti Terraform
terraform destroy -auto-approve

# 3. Patikrinti ar resource groups tušti
aws resource-groups list-group-resources \
  --group-name financeflow-terraform-resources
```

---

## Monitoring & Alerts

### CloudWatch Alarm su Resource Group

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name FinanceFlow-High-DynamoDB-ReadCapacity \
  --alarm-description "Alert when DynamoDB read capacity exceeds threshold" \
  --metric-name ConsumedReadCapacityUnits \
  --namespace AWS/DynamoDB \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 1000 \
  --comparison-operator GreaterThanThreshold
```

---

## Automation Scripts

### PowerShell: Gauti visų resource group resursų sąrašą

```powershell
$groups = @(
    "financeflow-terraform-resources",
    "financeflow-terraform-compute",
    "financeflow-terraform-network",
    "financeflow-terraform-database",
    "financeflow-terraform-security",
    "financeflow-terraform-cdn-lb",
    "financeflow-terraform-prod"
)

foreach ($group in $groups) {
    Write-Host "=== $group ===" -ForegroundColor Cyan
    aws resource-groups list-group-resources `
        --group-name $group `
        --query 'Resources[*].[ResourceType, Identifier]' `
        --output table
    Write-Host ""
}
```

### Python: Export resource inventory to CSV

```python
import boto3
import csv

client = boto3.client('resource-groups')

group_name = 'financeflow-terraform-resources'
response = client.list_group_resources(GroupName=group_name)

with open('financeflow-resources.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['ResourceType', 'ARN', 'Tags'])
    
    for resource in response['Resources']:
        writer.writerow([
            resource['ResourceType'],
            resource['Identifier'],
            resource.get('Tags', {})
        ])

print(f"Exported {len(response['Resources'])} resources to financeflow-resources.csv")
```

---

## Best Practices

1. **Regular Audits:** Kartą per mėnesį patikrinti resource group composition
2. **Cost Monitoring:** Naudoti tags su Cost Explorer kainų analizei
3. **Naming Convention:** Visi resource groups prasideda `financeflow-terraform-`
4. **Tag Consistency:** Užtikrinti, kad visi nauji resursai turi reikiamus tags
5. **Documentation:** Atnaujinti RESOURCE-GROUPS.md kai pridedami nauji tipai

---

## Troubleshooting

### Resource nerodomas grupėje
1. Patikrinti ar resource turi reikiamus tags
2. Palaukti 1-2 minutes (tag propagation laikas)
3. Patikrinti resource type filter

### Resource group tuščias po Terraform apply
1. Patikrinti ar tags teisingai nustatyti `main.tf`
2. Patikrinti `common_tags` local variable
3. Palaukti tag replication (iki 2 min)

### Cost tracking nerodo duomenų
1. Aktyvuoti Cost Allocation Tags AWS Console
2. Billing → Cost Allocation Tags → Activate tags
3. Palaukti 24h duomenų atsinaujinimui
