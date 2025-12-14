# Fix Terraform Cloud Variable Warnings

## ⚠️ Issue

Terraform Cloud workspace has AWS credentials set as **Terraform variables** instead of **Environment variables**, causing warnings:

```
Warning: Value for undeclared variable
The root module does not declare a variable named "AWS_DEFAULT_REGION"
The root module does not declare a variable named "AWS_SECRET_ACCESS_KEY"
The root module does not declare a variable named "AWS_ACCESS_KEY_ID"
```

## ✅ Solution

AWS credentials should be **Environment Variables**, not Terraform Variables.

### Step-by-Step Fix

1. **Open Terraform Cloud Workspace Variables:**
   https://app.terraform.io/app/UniversityThesis/workspaces/financemanager-infra-tf-aws/variables

2. **Delete these Terraform Variables** (if they exist):
   - ❌ `AWS_ACCESS_KEY_ID` (Terraform variable)
   - ❌ `AWS_SECRET_ACCESS_KEY` (Terraform variable)
   - ❌ `AWS_DEFAULT_REGION` (Terraform variable)

3. **Add as Environment Variables instead:**

   **Environment Variable 1:**
   - Key: `AWS_ACCESS_KEY_ID`
   - Value: `<your-access-key>`
   - Category: **Environment variable**
   - Sensitive: ✅ **Yes**

   **Environment Variable 2:**
   - Key: `AWS_SECRET_ACCESS_KEY`
   - Value: `<your-secret-key>`
   - Category: **Environment variable**
   - Sensitive: ✅ **Yes**

   **Environment Variable 3:**
   - Key: `AWS_DEFAULT_REGION`
   - Value: `eu-central-1`
   - Category: **Environment variable**
   - Sensitive: ❌ No

4. **Save Variables**

5. **Test with a new run:**
   ```powershell
   cd terraform\aws
   git commit --allow-empty -m "test: verify variable fix"
   git push origin fix
   ```

## 📋 Expected Result

After fixing:
- ✅ No warnings about undeclared variables
- ✅ AWS credentials work (loaded as environment variables)
- ✅ Terraform plan succeeds without warnings

## 🔍 Verification

Check run logs in Terraform Cloud - warnings should be gone:
https://app.terraform.io/app/UniversityThesis/workspaces/financemanager-infra-tf-aws/runs

## 📖 Reference

**Terraform Variables vs Environment Variables:**

| Type | Purpose | Example |
|------|---------|---------|
| **Terraform Variables** | Infrastructure config (declared in `variables.tf`) | `environment`, `aws_region`, `ecs_cpu` |
| **Environment Variables** | Runtime secrets, AWS creds | `AWS_ACCESS_KEY_ID`, `OPENAI_API_KEY` |

AWS credentials should **NEVER** be Terraform variables because they're not part of infrastructure configuration - they're runtime authentication credentials.

---

**Workspace URL:** https://app.terraform.io/app/UniversityThesis/workspaces/financemanager-infra-tf-aws/variables
