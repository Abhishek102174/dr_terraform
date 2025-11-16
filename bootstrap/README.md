# Terraform Backend Bootstrap - Complete Beginner Guide

## 🏗️ Why Single Backend Architecture?

**This bootstrap creates ONE backend per environment (not per module). Here's why this is the best approach:**

### ✅ **Advantages of Single Shared Backend:**

**Dependency Management:**
- Solr module can directly reference VPC outputs: `module.vpc.vpc_id`
- No complex remote state data sources needed
- Terraform automatically handles module dependencies

**Atomic Operations:**
- Deploy VPC and Solr together safely in one operation
- Single `terraform apply` updates everything in correct order
- Rollback affects all related infrastructure consistently

**State Consistency:**
- No risk of modules getting out of sync
- Single source of truth per environment
- All infrastructure changes visible in one place

**Simplified Management:**
- One state file to backup per environment
- One DynamoDB lock table per environment
- Fewer AWS resources to manage and monitor

**Team Collaboration:**
- Shared visibility of all infrastructure state
- No coordination needed between module teams
- Clear dependency relationships in state

### ❌ **Problems with Separate Module Backends:**

**Dependency Hell:**
```hcl
# With separate backends, you'd need complex remote state:
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vpc-state-bucket"
    key    = "vpc/terraform.tfstate"
  }
}

# Instead of simple module reference:
subnet_ids = module.vpc.private_subnet_ids
```

**Coordination Issues:**
- VPC team deploys first, then Solr team
- Risk of state drift between modules
- Complex deployment orchestration needed

**Infrastructure Overhead:**
- 6 S3 buckets instead of 3 (VPC + Solr × 3 environments)
- 6 DynamoDB tables instead of 3
- Higher AWS costs and management complexity

### 🎯 **Your Architecture Decision:**

```
✅ CHOSEN: Single Backend per Environment
dr-terraform-state-dr/
└── dr/infrastructure.tfstate  ← VPC + Solr + Future modules

❌ AVOIDED: Multiple Backends per Module
vpc-state-dr/vpc.tfstate
solr-state-dr/solr.tfstate
```

**Result:** You get modular workflows (separate CI/CD files) with unified state management (single backend). Best of both worlds! 🎉

## 🤔 What is Bootstrap and Why Do We Need It?

**The Problem**: Terraform needs a place to store its "state file" (a record of what infrastructure it created). By default, this file is stored locally, but for teams and CI/CD, we need it stored remotely in AWS S3.

**The Chicken-and-Egg Problem**: We need AWS infrastructure (S3 bucket + DynamoDB table) to store Terraform state, but we need Terraform to create that infrastructure!

**The Solution**: Bootstrap! We create the backend infrastructure FIRST using local state, then switch our main project to use that remote backend.

## 📋 What Bootstrap Creates

- **S3 Bucket**: Stores your Terraform state files securely
- **DynamoDB Table**: Prevents multiple people from running Terraform at the same time (state locking)
- **Security Settings**: Encryption, versioning, and access controls

## 🚀 Step-by-Step Setup (First Time Only)

### Step 1: Understand the Structure
```
dr_terraform/
├── bootstrap/              ← Creates backend infrastructure (run once)
│   ├── main.tf            ← Defines S3 bucket and DynamoDB table
│   ├── setup.sh           ← Automated setup script
│   └── terraform.tfvars.* ← Environment-specific settings
├── backend-configs/        ← Backend connection settings
│   ├── dr.hcl             ← Points to DR environment backend
│   ├── stage.hcl          ← Points to Stage environment backend
│   └── prod.hcl           ← Points to Prod environment backend
└── main.tf                ← Your actual infrastructure code
```

### Step 2: Run Bootstrap (One Environment at a Time)

**For DR Environment:**
```bash
# Navigate to bootstrap directory
cd bootstrap

# Run the automated setup script
./setup.sh dr
```

**What happens during bootstrap:**
1. ✅ Creates S3 bucket named `dr-terraform-state-dr`
2. ✅ Creates DynamoDB table named `dr-terraform-locks-dr`
3. ✅ Configures security (encryption, versioning, access controls)
4. ✅ Shows you the exact names created

**Expected Output:**
```
🚀 Setting up Terraform backend for environment: dr
✅ Backend infrastructure created successfully!

📋 Backend Configuration:
  S3 Bucket: dr-terraform-state-dr
  DynamoDB Table: dr-terraform-locks-dr

🔧 Next steps:
1. Update backend-configs/dr.hcl with the actual bucket name
2. Run 'terraform init -backend-config=backend-configs/dr.hcl' in the main directory
3. Commit and push the changes to trigger CI/CD
```

### Step 3: Update Backend Configuration Files

The bootstrap created resources with specific names. Now update the config files:

**Edit `../backend-configs/dr.hcl`:**
```hcl
bucket         = "dr-terraform-state-dr"          ← Use EXACT name from bootstrap output
key            = "dr/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "dr-terraform-locks-dr"         ← Use EXACT name from bootstrap output
encrypt        = true
```

### Step 4: Test the Backend Connection

```bash
# Go back to main directory
cd ..

# Initialize Terraform with the new backend
terraform init -backend-config=backend-configs/dr.hcl
```

**Expected Output:**
```
Initializing the backend...
Successfully configured the backend "s3"!
```

### Step 5: Repeat for Other Environments (Optional)

```bash
# For Stage environment
cd bootstrap
./setup.sh stage
# Then update ../backend-configs/stage.hcl

# For Production environment  
./setup.sh prod
# Then update ../backend-configs/prod.hcl
```

## 🔧 Manual Steps (If Automated Script Fails)

If `./setup.sh` doesn't work, you can run commands manually:

```bash
cd bootstrap

# 1. Initialize Terraform (downloads AWS provider)
terraform init

# 2. See what will be created
terraform plan -var-file="terraform.tfvars.dr"

# 3. Create the infrastructure
terraform apply -var-file="terraform.tfvars.dr"
# Type 'yes' when prompted

# 4. See what was created
terraform output
```

## ❓ Common Questions

**Q: Do I need to run bootstrap for every environment?**
A: Yes, each environment (dr, stage, prod) gets its own S3 bucket and DynamoDB table for security isolation.

**Q: What if I already have an S3 bucket I want to use?**
A: You can import it: `terraform import aws_s3_bucket.terraform_state your-existing-bucket-name`

**Q: Can I delete the bootstrap directory after setup?**
A: NO! Keep it safe. If you lose it, you lose the ability to manage your backend infrastructure.

**Q: What happens if bootstrap fails?**
A: Check the error message. Common issues:
- AWS credentials not configured
- Bucket name already exists (try different name)
- Insufficient AWS permissions

## 🚨 Important Warnings

- **Run bootstrap ONLY ONCE per environment**
- **Keep bootstrap directory safe** - it manages your backend
- **Don't modify backend configs manually** without understanding the impact
- **Each environment is isolated** - dr, stage, and prod are completely separate

## 🧹 Cleanup (⚠️ DANGER ZONE)

**Only do this if you want to completely destroy everything:**

```bash
# This will delete ALL your Terraform state!
terraform destroy -var-file="terraform.tfvars.dr"
```

## 🆘 Troubleshooting

### Error: "Bucket already exists"
```bash
# Solution 1: Use different bucket name in terraform.tfvars.dr
# Solution 2: Import existing bucket
terraform import aws_s3_bucket.terraform_state existing-bucket-name
```

### Error: "State is locked"
```bash
# Check who has the lock
terraform show

# Force unlock (CAREFUL!)
terraform force-unlock LOCK_ID
```

### Error: "Access denied"
```bash
# Check your AWS credentials
aws sts get-caller-identity

# Make sure your AWS role has permissions for:
# - S3 (create buckets, manage objects)
# - DynamoDB (create tables)
```

### Error: "Backend configuration changed"
```bash
# Reinitialize with new backend config
terraform init -reconfigure -backend-config=backend-configs/dr.hcl
```

## 📚 Next Steps

After bootstrap is complete:
1. ✅ Your CI/CD pipeline will automatically use the remote backend
2. ✅ Multiple team members can work on the same infrastructure
3. ✅ State is safely stored and locked in AWS
4. ✅ You can proceed with normal Terraform development
