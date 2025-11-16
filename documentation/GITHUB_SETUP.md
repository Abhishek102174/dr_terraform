# GitHub Multi-Environment CI/CD Setup Guide

This guide provides complete instructions for setting up GitHub Actions CI/CD for the DR Terraform project with multi-environment support (DR, Stage, Production).

## 🏗️ **Architecture Overview**

```
GitHub Actions Workflows:
├── bootstrap.yml           ← Creates S3/DynamoDB backend (run once)
├── vpc-module.yml          ← VPC infrastructure CI/CD
└── solr-stack-module.yml   ← Solr application CI/CD

Environments:
├── DR (us-east-1)          ← Auto-deploy from main branch
├── Stage (us-east-1)       ← Manual approval required
└── Production (us-east-1)  ← Manual approval + main branch only
```

## 🚀 **Complete Setup Instructions**

### **Step 1: AWS Infrastructure Setup**

#### **1.1 Create OIDC Identity Provider**

**Console Approach:**
1. Go to **IAM → Identity providers → Add provider**
2. **Provider type**: OpenID Connect
3. **Provider URL**: `https://token.actions.githubusercontent.com`
4. **Audience**: `sts.amazonaws.com`
5. **Thumbprint**: `6938fd4d98bab03faadb97b34396831e3780aea1`
6. Click **Add provider**

**CLI Approach:**
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com
```

#### **1.2 Create IAM Roles (One per Environment)**

**Console Approach:**
1. Go to **IAM → Roles → Create role**
2. **Trusted entity type**: Web identity
3. **Identity provider**: `token.actions.githubusercontent.com`
4. **Audience**: `sts.amazonaws.com`
5. **GitHub organization**: `YOUR-ORG`
6. **GitHub repository**: `YOUR-REPO`
7. **Branch**: `*` (all branches)
8. **Role name**: `github-actions-dr-role` (repeat for stage, prod)
9. **Attach policies**: Create custom policy with permissions below

**CLI Approach:**
```bash
# Create trust policy file
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR-ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR-ORG/YOUR-REPO:*"
        }
      }
    }
  ]
}
EOF

# Create roles
aws iam create-role --role-name github-actions-dr-role --assume-role-policy-document file://trust-policy.json
aws iam create-role --role-name github-actions-stage-role --assume-role-policy-document file://trust-policy.json
aws iam create-role --role-name github-actions-prod-role --assume-role-policy-document file://trust-policy.json
```

**Required Permissions Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elbv2:*",
        "autoscaling:*",
        "iam:PassRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:ListRoles",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "s3:*",
        "efs:*",
        "dynamodb:*",
        "route53:*",
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### **Step 2: SSH Key Generation**

**Generate SSH Keys for Each Environment:**
```bash
# DR Environment
ssh-keygen -t rsa -b 4096 -f ~/.ssh/solr-dr-key -C "solr-dr-access"

# Stage Environment  
ssh-keygen -t rsa -b 4096 -f ~/.ssh/solr-stage-key -C "solr-stage-access"

# Production Environment
ssh-keygen -t rsa -b 4096 -f ~/.ssh/solr-prod-key -C "solr-prod-access"
```

**Extract Public Key Content:**
```bash
# Copy these outputs for GitHub Secrets
cat ~/.ssh/solr-dr-key.pub
cat ~/.ssh/solr-stage-key.pub  
cat ~/.ssh/solr-prod-key.pub
```

**⚠️ Security Note:** Keep private keys secure and never commit them to Git!

### **Step 3: GitHub Repository Configuration**

#### **3.1 GitHub Secrets**
Go to **Repository → Settings → Secrets and variables → Actions → Secrets**

**AWS OIDC Role ARNs:**
```
Name: AWS_ROLE_ARN_DR
Value: arn:aws:iam::YOUR-ACCOUNT-ID:role/github-actions-dr-role

Name: AWS_ROLE_ARN_STAGE  
Value: arn:aws:iam::YOUR-ACCOUNT-ID:role/github-actions-stage-role

Name: AWS_ROLE_ARN_PROD
Value: arn:aws:iam::YOUR-ACCOUNT-ID:role/github-actions-prod-role
```

**SSH Key Names (EC2 Key Pair Names):**
```
Name: SOLR_KEY_NAME_DR
Value: solr-dr-keypair

Name: SOLR_KEY_NAME_STAGE
Value: solr-stage-keypair

Name: SOLR_KEY_NAME_PROD  
Value: solr-prod-keypair
```

**SSH Public Keys:**
```
Name: SOLR_PUBLIC_KEY_DR
Value: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... (from ~/.ssh/solr-dr-key.pub)

Name: SOLR_PUBLIC_KEY_STAGE
Value: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... (from ~/.ssh/solr-stage-key.pub)

Name: SOLR_PUBLIC_KEY_PROD
Value: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... (from ~/.ssh/solr-prod-key.pub)
```

**Optional Secrets:**
```
Name: INFRACOST_API_KEY
Value: ico-xxx... (from infracost.io for cost estimation)
```

#### **3.2 GitHub Variables**
Go to **Repository → Settings → Secrets and variables → Actions → Variables**

**Feature Flags for Apply Operations:**
```
Name: FEATURE_VPC_SETUP
Value: true

Name: FEATURE_SOLR_SETUP  
Value: true
```

**Feature Flags for Destroy Operations (Safety First):**
```
Name: FEATURE_VPC_DESTROY
Value: false

Name: FEATURE_SOLR_DESTROY
Value: false
```

#### **3.3 GitHub Environment Protection**
Go to **Repository → Settings → Environments**

**Apply Environments:**
- **Environment name**: `dr`
  - **Deployment branches**: No restrictions
  - **Environment protection rules**: None (auto-deploy)

- **Environment name**: `stage`
  - **Deployment branches**: Selected branches → `main`, `develop`
  - **Environment protection rules**: ✅ Required reviewers (1-2 people)

- **Environment name**: `prod`
  - **Deployment branches**: Selected branches → `main` only
  - **Environment protection rules**: ✅ Required reviewers (2+ people)

**Destroy Environments (Extra Protection):**
- **Environment name**: `dr-destroy`
  - **Environment protection rules**: ✅ Required reviewers (1 person)

- **Environment name**: `stage-destroy`
  - **Environment protection rules**: ✅ Required reviewers (1-2 people)

- **Environment name**: `prod-destroy`
  - **Environment protection rules**: ✅ Required reviewers (2+ people)

**Bootstrap Environments:**
- **Environment name**: `dr-bootstrap`
  - **Environment protection rules**: ✅ Required reviewers (1 person)

- **Environment name**: `stage-bootstrap`
  - **Environment protection rules**: ✅ Required reviewers (1 person)

- **Environment name**: `prod-bootstrap`
  - **Environment protection rules**: ✅ Required reviewers (1 person)

### **Step 4: Update Environment Configuration**

#### **4.1 Find Your Solr AMI IDs**
```bash
# List available Solr AMIs
aws ec2 describe-images \
  --owners self \
  --filters "Name=name,Values=solr-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table
```

#### **4.2 Update Environment JSON Files**
Update the AMI IDs in your environment files:

**`environments/dr.json`:**
```json
{
  "solr_fallback_ami_id": "ami-your-actual-dr-ami-id",
  // ... rest of config
}
```

**`environments/stage.json`:**
```json
{
  "solr_fallback_ami_id": "ami-your-actual-stage-ami-id", 
  // ... rest of config
}
```

**`environments/prod.json`:**
```json
{
  "solr_fallback_ami_id": "ami-your-actual-prod-ami-id",
  // ... rest of config  
}
```

## 🎯 **First Time Deployment Process**

### **Step 1: Bootstrap Backend Infrastructure**

**⚠️ Important:** Run bootstrap BEFORE any other workflows!

1. Go to **Actions → Bootstrap Terraform Backend**
2. **Run workflow** with:
   - **Environment**: `dr`
   - **Action**: `create`
3. **Approve** the workflow in the `dr-bootstrap` environment
4. **Merge** the auto-created PR that updates backend configuration
5. **Repeat** for `stage` and `prod` environments

### **Step 2: Verify Backend Setup**
After bootstrap completes, verify backend configs are updated:
```bash
# Check that backend configs have actual bucket names
cat backend-configs/dr.hcl
cat backend-configs/stage.hcl  
cat backend-configs/prod.hcl
```

### **Step 3: Normal Development Workflow**

**Automatic Deployment (Recommended):**
1. **Create feature branch**: `git checkout -b feature/vpc-updates`
2. **Make changes** to VPC or Solr modules
3. **Create pull request** to `main` branch
4. **Review results** in PR comments (separate comments per module/environment)
5. **Merge PR** → Automatically deploys to DR environment

**Manual Deployment:**
1. Go to **Actions → VPC Module CI/CD** or **Solr Stack Module CI/CD**
2. **Run workflow** with:
   - **Environment**: `stage` or `prod`
   - **Action**: `apply`
3. **Approve** the deployment in GitHub environment protection

## 🔧 **Feature Flag Management**

### **Enable/Disable Deployments**
To control which modules can deploy:

**Allow VPC deployments:**
```
FEATURE_VPC_SETUP = true
```

**Block Solr deployments:**
```
FEATURE_SOLR_SETUP = false
```

### **Enable Destroy Operations (⚠️ Use Carefully)**
To allow infrastructure destruction:

1. **Set feature flag**: `FEATURE_VPC_DESTROY = true`
2. **Run destroy workflow**: Actions → Module workflow → Environment + `destroy`
3. **Approve operation**: In GitHub environment protection
4. **Reset flag**: `FEATURE_VPC_DESTROY = false` (recommended)

## 🛡️ **Security Features**

- ✅ **OIDC Authentication** - No long-lived AWS credentials stored
- ✅ **Environment Isolation** - Separate AWS roles per environment  
- ✅ **Manual Approvals** - Required for stage/prod operations
- ✅ **Feature Flag Protection** - Prevent accidental deployments/destroys
- ✅ **Branch Protection** - Production restricted to main branch only
- ✅ **Destroy Protection** - Extra approval environments for destroy operations
- ✅ **Audit Trail** - All operations logged in GitHub Actions

## 🆘 **Troubleshooting**

### **Common Issues**

**OIDC Authentication Failed:**
- Verify IAM role trust policy includes your repository
- Check GitHub secrets have correct role ARNs
- Ensure OIDC provider exists in AWS

**Backend Not Found:**
- Run bootstrap workflow first
- Check backend config files have actual bucket names
- Verify S3 bucket and DynamoDB table exist

**Feature Flag Blocked:**
- Check GitHub Variables are set correctly
- Verify feature flags are `"true"` (string, not boolean)
- For destroy: ensure destroy feature flags are enabled

**Environment Protection:**
- Verify environments are created in GitHub
- Check required reviewers are configured
- Ensure branch restrictions match your workflow

### **Debug Steps**
1. **Check workflow logs** in Actions tab
2. **Verify AWS credentials** configuration  
3. **Test Terraform commands** locally
4. **Review IAM role permissions** and trust policy

## 📋 **Setup Checklist**

### **AWS Setup:**
- [ ] OIDC Identity Provider created
- [ ] 3 IAM roles created (dr, stage, prod)
- [ ] Trust policies configured with your repository
- [ ] Permissions policies attached
- [ ] SSH key pairs generated

### **GitHub Secrets (9 required):**
- [ ] `AWS_ROLE_ARN_DR`
- [ ] `AWS_ROLE_ARN_STAGE`
- [ ] `AWS_ROLE_ARN_PROD`
- [ ] `SOLR_KEY_NAME_DR`
- [ ] `SOLR_KEY_NAME_STAGE`
- [ ] `SOLR_KEY_NAME_PROD`
- [ ] `SOLR_PUBLIC_KEY_DR`
- [ ] `SOLR_PUBLIC_KEY_STAGE`
- [ ] `SOLR_PUBLIC_KEY_PROD`

### **GitHub Variables (4 required):**
- [ ] `FEATURE_VPC_SETUP = true`
- [ ] `FEATURE_SOLR_SETUP = true`
- [ ] `FEATURE_VPC_DESTROY = false`
- [ ] `FEATURE_SOLR_DESTROY = false`

### **GitHub Environments (9 required):**
- [ ] `dr`, `stage`, `prod` (apply environments)
- [ ] `dr-destroy`, `stage-destroy`, `prod-destroy` (destroy environments)
- [ ] `dr-bootstrap`, `stage-bootstrap`, `prod-bootstrap` (bootstrap environments)

### **Environment Files:**
- [ ] AMI IDs updated in all 3 environment JSON files
- [ ] Backend bootstrap completed for all environments
- [ ] Backend config PRs merged

## 🎉 **Success Indicators**

- ✅ **Bootstrap workflows** complete successfully
- ✅ **Backend config PRs** auto-created and merged
- ✅ **Pull requests** show validation results for all modules/environments
- ✅ **Main branch pushes** auto-deploy to DR environment
- ✅ **Manual deployments** work with approval process
- ✅ **Feature flags** control deployment behavior
- ✅ **Destroy operations** require explicit feature flag + approval

Your multi-environment CI/CD pipeline is now ready for enterprise-grade infrastructure management! 🚀
