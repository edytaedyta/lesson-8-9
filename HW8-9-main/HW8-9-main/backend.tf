# Backend Configuration
# Run the following command before terraform init to configure the backend:
# terraform init -backend-config="bucket=<s3-bucket-name>" -backend-config="dynamodb_table=<dynamodb-table-name>"
#
# Where:
#   <s3-bucket-name> - The S3 bucket you created for storing Terraform state
#   <dynamodb-table-name> - The DynamoDB table you created for state locking
#
# Example:
# terraform init -backend-config="bucket=my-terraform-state-20240104120000" -backend-config="dynamodb_table=terraform-locks"
