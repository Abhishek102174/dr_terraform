# DR Terraform Module Workflows

## 📁 What's in This Directory

**4 workflow files - one per module:**
- `bootstrap.yml` - **Creates backend infrastructure** (run first, once per environment)
- `vpc-module.yml` - **VPC Module CI/CD** (network infrastructure)
- `solr-stack-module.yml` - **Solr Stack Module CI/CD** (application infrastructure)
- `README.md` - **This guide** (explains everything)

## 🏗️ Module-Based Architecture

Each module has its own dedicated workflow file with multi-environment support:

### **VPC Module** (`vpc-module.yml`)
- **Path Triggers:** `modules/network/vpc/**`, `modules/network/networking/**`
- **Working Directory:** `./modules/network/vpc`
- **Purpose:** Network infrastructure (VPC, subnets, gateways, routing)

### **Solr Stack Module** (`solr-stack-module.yml`)
- **Path Triggers:** `modules/solr_stack_dr/**`
- **Working Directory:** `./modules/solr_stack_dr`
- **Purpose:** Application infrastructure (EC2, EFS, ALB, Auto Scaling, IAM)
- **Extra Features:** Checkov security scanning

## 🔄 Workflow Structure (Per Module)

### **Pre-Apply Jobs (Validation & Planning):**
```
{module}_pre_apply_dr     - Validates module for DR environment
{module}_pre_apply_stage  - Validates module for Stage environment
{module}_pre_apply_prod   - Validates module for Prod environment
```

### **Apply Jobs (Deployment):**
```
{module}_apply_dr    - Deploys to DR (auto on main push)
{module}_apply_stage - Deploys to Stage (manual only)
{module}_apply_prod  - Deploys to Prod (manual only)
```

## 🚀 Complete Setup Process

### Step 1: Bootstrap Backend (First Time Only)

**Run for each environment:**
1. Actions → **Bootstrap Terraform Backend** → `dr` → `create`
2. Actions → **Bootstrap Terraform Backend** → `stage` → `create`  
3. Actions → **Bootstrap Terraform Backend** → `prod` → `create`
4. Merge the auto-created PRs for each environment

### Step 2: Module Development

**Normal workflow:**
1. **Create branch** → Make changes to VPC or Solr modules
2. **Create PR** → Triggers relevant module workflows automatically
3. **Review results** - Separate PR comments per module/environment
4. **Merge PR** → Auto-deploys to DR environment

## 📖 How to Use

### Automatic Deployment (Recommended)
1. **Create branch:** `git checkout -b feature/vpc-changes`
2. **Make changes** to specific module files
3. **Create PR** to `main`
4. **Only affected modules run** - If you change VPC files, only VPC workflow runs
5. **Review module-specific results** in PR comments
6. **Merge PR** → Auto-deploys changed modules to DR

### Manual Deployment
**Deploy specific module to specific environment:**

**VPC Module:**
- Actions → **VPC Module CI/CD** → Choose environment and action

**Solr Stack Module:**
- Actions → **Solr Stack Module CI/CD** → Choose environment and action

**Examples:**
- Deploy VPC to Stage: VPC Module workflow → Environment=`stage`, Action=`apply`
- Deploy Solr to Prod: Solr Stack workflow → Environment=`prod`, Action=`apply`

## 🔍 Understanding PR Results

### Path-Based Triggering:
- **Change VPC files** → Only VPC workflow runs → VPC PR comments
- **Change Solr files** → Only Solr workflow runs → Solr PR comments
- **Change both** → Both workflows run → Comments from both modules

### PR Comment Format:
```
#### VPC Module - DR Environment 🌐
#### Terraform Format and Style 🖌 ✅
#### Terraform Initialization ⚙️ ✅  
#### Terraform Plan 📖 ✅

<details><summary>Show VPC DR Plan</summary>
Plan: 3 to add, 0 to change, 0 to destroy.
</details>
```

## 🎯 Module-Specific Features

### VPC Module (`vpc-module.yml`):
- **Triggers on:** Changes to `modules/network/vpc/**` or `modules/network/networking/**`
- **Validates:** Network infrastructure components
- **Plans:** VPC, subnets, internet gateways, NAT gateways, routing tables
- **Auto-deploys:** To DR on main branch push

### Solr Stack Module (`solr-stack-module.yml`):
- **Triggers on:** Changes to `modules/solr_stack_dr/**`
- **Validates:** Application infrastructure components
- **Security:** Checkov security scanning with SARIF upload
- **Plans:** EC2 instances, EFS, ALB, Auto Scaling groups, IAM roles
- **Auto-deploys:** To DR on main branch push

## 🔧 Environment-Specific Behavior

### **DR Environment:**
- **Auto-deploy:** Both modules auto-deploy on main branch push
- **Manual approval:** Not required for apply operations
- **Backend:** Uses `backend-configs/dr.hcl`

### **Stage Environment:**
- **Manual only:** Requires manual workflow dispatch
- **Manual approval:** Required through GitHub environment protection
- **Backend:** Uses `backend-configs/stage.hcl`

### **Production Environment:**
- **Manual only:** Requires manual workflow dispatch
- **Manual approval:** Required + restricted to main branch
- **Backend:** Uses `backend-configs/prod.hcl`

## 🎯 Quick Reference

**File Structure:**
```
.github/workflows/
├── bootstrap.yml           ← Backend setup
├── vpc-module.yml          ← VPC infrastructure
├── solr-stack-module.yml   ← Solr application
└── README.md              ← This guide

modules/
├── network/vpc/           ← Triggers vpc-module.yml
└── solr_stack_dr/         ← Triggers solr-stack-module.yml
```

**Workflow Naming:**
- **VPC Module CI/CD** - Network infrastructure workflow
- **Solr Stack Module CI/CD** - Application infrastructure workflow
- **Bootstrap Terraform Backend** - Backend setup workflow

**Benefits of Separate Workflows:**
- ✅ **Faster execution** - Only affected modules run
- ✅ **Clearer results** - Module-specific PR comments
- ✅ **Independent deployment** - Deploy modules separately
- ✅ **Easier maintenance** - Module teams own their workflows
- ✅ **Reduced noise** - No irrelevant workflow runs
