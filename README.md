# terraform-aws-docker-host

The AWS environment from [aws-docker-host-cli](../aws-docker-host-cli) as **Terraform**: a reusable `vpc` module and a `webserver` module composed in `envs/dev`, with remote state in S3 and DynamoDB locking.

```
envs/dev/main.tf ──► module "vpc"       (VPC, public subnet, IGW, route table)
                 └─► module "webserver" (SG, key pair, EC2 + user-data → Docker, Elastic IP)
```

## Usage
```bash
cd envs/dev
cp terraform.tfvars.example terraform.tfvars      # my_ip, ssh_public_key
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
terraform output public_ip
terraform destroy
```

## Design notes
- Providers, resources, variables with validation, outputs, `locals`, `data` sources (latest Ubuntu AMI).
- Modules with explicit inputs/outputs; no provider blocks inside modules.
- Remote backend (`backend.tf`) so state is shared and locked; `.gitignore` for state and tfvars.
- `terraform fmt` / `validate` in CI; `-out` plan files so apply runs exactly what was reviewed.

