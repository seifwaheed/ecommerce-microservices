# GitHub Setup - Quick Steps

## 🚀 5-Minute GitHub Setup

### Step 1: Create Repository (2 min)

1. Go to **https://github.com** → Sign in
2. Click **"+"** → **"New repository"**
3. Name: `cloud`
4. Click **"Create repository"**

---

### Step 2: Push Code (2 min)

**In PowerShell:**

```powershell
cd C:\Users\User\Downloads\cloud

# Initialize git (if needed)
git init

# Add files
git add .

# Commit
git commit -m "Initial commit"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/cloud.git

# Push
git branch -M main
git push -u origin main
```

**Use GitHub username and Personal Access Token when prompted**

---

### Step 3: Add Secrets (1 min)

1. GitHub repo → **Settings** → **Secrets** → **Actions**
2. Click **"New repository secret"**
3. Add `DOCKER_USERNAME` = Your Docker Hub username
4. Add `DOCKER_PASSWORD` = Your Docker Hub password/token

---

### Step 4: Update Workflow (1 min)

1. Go to `.github/workflows/ci-cd.yml`
2. Click **"Edit"**
3. Change line 11: `IMAGE_PREFIX: yourusername` → Your Docker Hub username
4. Click **"Commit changes"**

---

### Step 5: Verify (1 min)

1. Go to **Actions** tab
2. See workflow running
3. Check Docker Hub for your images

**Done!** ✅

