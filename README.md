# FinanceFlow AWS Infrastructure - Terraform

Terraform infrastructure as code for FinanceFlow application on AWS.

## 🏗️ Architecture

- **VPC**: Custom VPC (10.10.0.0/16) with 3 AZs
- **Compute**: ECS Fargate + Lambda
- **Database**: DynamoDB (transactions, categories)
- **Auth**: Cognito User Pool
- **CDN**: CloudFront + ALB
- **Container Registry**: ECR

## 📁 Project Structure

```
financemanager-infra-tf-aws/
├── terraform/
│   └── aws/                    # Main Terraform configuration
│       ├── main.tf             # Root module
│       ├── providers.tf        # AWS provider config
│       ├── backend.tf          # Terraform Cloud backend
│       ├── variables.tf        # Input variables
│       ├── outputs.tf          # Output values
│       ├── versions.tf         # Terraform & provider versions
│       ├── modules/            # Reusable modules
│       │   ├── alb/
│       │   ├── api-gateway/
│       │   ├── auth/
│       │   ├── cloudfront/
│       │   ├── database/
│       │   ├── ecr/
│       │   ├── ecs/
│       │   ├── iam/
│       │   ├── lambda/
│       │   └── networking/
│       └── environments/
│           └── prod/
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Terraform >= 1.13.0
- AWS CLI configured
- Terraform Cloud account

### Terraform Cloud Setup

This project uses [Terraform Cloud](https://app.terraform.io) for state management.

**Workspace:** `UniversityThesis/financemanager-infra-tf-aws`

1. **Login to Terraform Cloud:**
   ```bash
   terraform login
   ```

2. **Initialize (from terraform/aws directory):**
   ```bash
   cd terraform/aws
   terraform init
   ```

3. **Set AWS Credentials in Terraform Cloud:**
   - Go to workspace settings
   - Add environment variables:
     - `AWS_ACCESS_KEY_ID` (sensitive)
     - `AWS_SECRET_ACCESS_KEY` (sensitive)

### Deployment

```bash
cd terraform/aws

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure (careful!)
terraform destroy
```

## 📊 Resources Managed

| Resource Type | Count | Description |
|---------------|-------|-------------|
| VPC | 1 | Custom VPC with 6 subnets (3 public, 3 private) |
| ECS Cluster | 1 | Fargate cluster for containerized app |
| Lambda | 1 | OpenAI integration function |
| DynamoDB | 2 | Transactions and categories tables |
| Cognito | 1 | User authentication pool |
| CloudFront | 1 | CDN distribution |
| ALB | 1 | Application Load Balancer |
| ECR | 1 | Container image registry |
| Resource Groups | 7 | Organized resource tracking |

**Total:** ~55 resources

## 🔐 Resource Groups

Resources are organized into logical groups for easy management:

- `financeflow-terraform-resources` - All resources
- `financeflow-terraform-compute` - ECS, Lambda
- `financeflow-terraform-network` - VPC, subnets, SGs
- `financeflow-terraform-database` - DynamoDB tables
- `financeflow-terraform-security` - Cognito
- `financeflow-terraform-cdn-lb` - CloudFront, ALB
- `financeflow-terraform-prod` - Production environment

View in AWS Console:
```bash
terraform output resource_group_console_urls
```

## 📝 Important Outputs

After applying, get important values:

```bash
# Application URL
terraform output app_url

# Cognito configuration
terraform output cognito_user_pool_id
terraform output cognito_client_id

# API endpoints
terraform output ai_api_url

# Deployment commands
terraform output deployment_commands
```

## 🏷️ Tagging Strategy

All resources are tagged with:
- `ManagedBy: terraform`
- `Project: financeflow`
- `Environment: prod`
- `Owner: thesis-student`
- `TerraformPrefix: tf_`

## 🔄 CI/CD Integration

Terraform Cloud is connected to GitHub repository with VCS-driven workflow:

1. Push to `main` or `fix` branch
2. Terraform Cloud automatically runs `plan`
3. Review plan in Terraform Cloud UI
4. Manually approve and apply changes

## 📚 Documentation

- [Infrastructure Implementation](./terraform/aws/1.2.4-Programine-Realizacija-Infra.md) - Thesis documentation
- [Resource Groups](./terraform/aws/RESOURCE-GROUPS-SUMMARY.md) - Resource organization
- [Cleanup Report](./terraform/aws/CLEANUP-COMPLETED.md) - POC resources cleanup

## 🛠️ Development

### Adding New Resources

1. Create/modify modules in `terraform/aws/modules/`
2. Reference in `terraform/aws/main.tf`
3. Add outputs to `terraform/aws/outputs.tf`
4. Run `terraform plan` to preview
5. Commit and push - Terraform Cloud will trigger automatically

### Module Structure

Each module should have:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `README.md` - Module documentation (optional)

## 🔗 Links

- **Terraform Cloud Workspace:** https://app.terraform.io/app/UniversityThesis/workspaces/financemanager-infra-tf-aws
- **GitHub Repository:** https://github.com/KayVee77/financemanager-infra-tf-aws
- **AWS Console:** eu-central-1 region

## 📞 Support

For issues or questions, create an issue in the GitHub repository.

## 📄 License

This project is part of a university thesis.
