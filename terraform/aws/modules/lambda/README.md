# Lambda Function Code

The Lambda module expects a `lambda.zip` file in this directory.

## Option 1: Manual Creation

1. Create `index.mjs` with the Lambda handler code
2. Zip it: `Compress-Archive -Path index.mjs -DestinationPath lambda.zip`

## Option 2: Use archive_file data source

Update `main.tf` to use Terraform's archive_file data source to create the zip automatically.

## Lambda Handler Code

Copy the Lambda code from `AWS_POC_SIMPLE_DEPLOYMENT.md` Part 3.4 into `index.mjs`.
