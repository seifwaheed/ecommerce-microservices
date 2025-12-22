# GitHub Setup - Complete Step-by-Step Guide

## 🎯 What You Need to Do on GitHub

This guide will walk you through everything step-by-step.

---

## Step 1: Create a GitHub Repository

### 1.1: Go to GitHub

1. Open your web browser
2. Go to: **https://github.com**
3. **Sign in** to your GitHub account (or create one if you don't have it)

### 1.2: Create New Repository

1. Click the **"+"** icon in the top right corner
2. Click **"New repository"**

### 1.3: Fill Repository Details

**Repository name:** `cloud` (or `ecommerce-microservices`)

**Description:** `E-Commerce Microservices with Kubernetes and ArgoCD`

**Visibility:**
- ✅ **Public** (recommended - free, CI/CD works better)
- ⚠️ **Private** (requires GitHub Pro for some CI/CD features)

**DO NOT check:**
- ❌ Add a README file (you already have one)
- ❌ Add .gitignore (you already have one)
- ❌ Choose a license (optional)

### 1.4: Create Repository

Click the green **"Create repository"** button

**You'll see a page with setup instructions - DON'T follow those yet!**

---

## Step 2: Push Your Code to GitHub

### 2.1: Open PowerShell in Your Project

Navigate to your project folder:
```powershell
cd C:\Users\User\Downloads\cloud
```

### 2.2: Initialize Git (if not already done)

```powershell
git init
```

### 2.3: Add All Files

```powershell
git add .
```

### 2.4: Create First Commit

```powershell
git commit -m "Initial commit: E-Commerce Microservices Project"
```

### 2.5: Add GitHub Remote

**Replace `YOUR_USERNAME` with your actual GitHub username:**

```powershell
git remote add origin https://github.com/YOUR_USERNAME/cloud.git
```

**Example:** If your username is `john123`, it would be:
```powershell
git remote add origin https://github.com/john123/cloud.git
```

### 2.6: Push to GitHub

```powershell
git branch -M main
git push -u origin main
```

**You'll be asked for your GitHub username and password/token**

**If it asks for password:** Use a **Personal Access Token** (not your password)
- Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
- Generate new token
- Give it `repo` permissions
- Copy the token and use it as password

---

## Step 3: Verify Code is on GitHub

### 3.1: Check Repository

1. Go to your GitHub repository page
2. You should see all your files:
   - ✅ `services/` folder
   - ✅ `dashboard/` folder
   - ✅ `k8s/` folder
   - ✅ `scripts/` folder
   - ✅ `README.md`
   - ✅ `.github/workflows/ci-cd.yml`

**If you see all these, your code is successfully pushed!** ✅

---

## Step 4: Configure CI/CD Secrets

### 4.1: Go to Repository Settings

1. In your GitHub repository page
2. Click **"Settings"** tab (top menu)
3. In the left sidebar, click **"Secrets and variables"**
4. Click **"Actions"**

### 4.2: Add Docker Hub Username Secret

1. Click **"New repository secret"** button
2. **Name:** `DOCKER_USERNAME`
3. **Secret:** Your Docker Hub username
   - Example: `john123`
4. Click **"Add secret"**

### 4.3: Add Docker Hub Password Secret

1. Click **"New repository secret"** button again
2. **Name:** `DOCKER_PASSWORD`
3. **Secret:** Your Docker Hub password OR access token
   - **Recommended:** Use an access token instead of password
   - Go to Docker Hub → Account Settings → Security → New Access Token
   - Create token with "Read, Write, Delete" permissions
   - Copy token and paste here
4. Click **"Add secret"**

### 4.4: Verify Secrets

You should now see:
- ✅ `DOCKER_USERNAME` (with eye icon to reveal)
- ✅ `DOCKER_PASSWORD` (with eye icon to reveal)

---

## Step 5: Update CI/CD Workflow File

### 5.1: Edit Workflow File on GitHub

1. Go to your repository
2. Navigate to: `.github/workflows/ci-cd.yml`
3. Click on the file
4. Click **"Edit"** button (pencil icon)

### 5.2: Update Image Prefix

Find this line (around line 11):
```yaml
IMAGE_PREFIX: yourusername
```

Change `yourusername` to your actual Docker Hub username:
```yaml
IMAGE_PREFIX: YOUR_DOCKERHUB_USERNAME
```

**Example:** If your Docker Hub username is `john123`:
```yaml
IMAGE_PREFIX: john123
```

### 5.3: Commit Changes

1. Scroll down to the bottom
2. **Commit message:** `Update CI/CD with Docker Hub username`
3. Click **"Commit changes"** button

---

## Step 6: Update ArgoCD Application Files (Optional)

### 6.1: Edit ArgoCD Application Files

If you plan to use ArgoCD, update the repository URLs:

1. Go to `argocd/applications/ecommerce-app.yaml`
2. Click **"Edit"**
3. Find this line:
```yaml
repoURL: https://github.com/yourusername/cloud.git
```
4. Change `yourusername` to your GitHub username
5. Click **"Commit changes"**

6. Repeat for `argocd/applications/kafka-app.yaml`

---

## Step 7: Trigger CI/CD Pipeline

### 7.1: Make a Small Change to Trigger Workflow

**Option A: Update README**
1. Go to `README.md`
2. Click **"Edit"**
3. Add a line at the top: `# Updated: [Today's Date]`
4. Click **"Commit changes"**

**Option B: Push from Local**

```powershell
# Make a small change
echo "# Updated" >> README.md

# Commit and push
git add README.md
git commit -m "Trigger CI/CD"
git push origin main
```

### 7.2: Check GitHub Actions

1. Go to your repository
2. Click **"Actions"** tab
3. You should see a workflow run starting!
4. Click on it to see progress

**What you'll see:**
- ✅ Yellow circle = Running
- ✅ Green checkmark = Success
- ❌ Red X = Failed (check logs)

---

## Step 8: Verify CI/CD is Working

### 8.1: Check Workflow Run

1. Go to **Actions** tab
2. Click on the latest workflow run
3. You should see:
   - ✅ `build-and-test` job running/completed
   - ✅ `deploy` job (if on main branch)

### 8.2: Check Docker Hub

1. Go to **https://hub.docker.com**
2. Sign in
3. Go to **"Repositories"**
4. You should see:
   - ✅ `YOUR_USERNAME/catalog-service`
   - ✅ `YOUR_USERNAME/cart-service`
   - ✅ `YOUR_USERNAME/order-service`
   - ✅ `YOUR_USERNAME/payment-service`
   - ✅ `YOUR_USERNAME/dashboard`

**If you see these, CI/CD is working!** 🎉

---

## 📋 Complete Checklist

### GitHub Repository:
- [ ] Created GitHub repository
- [ ] Pushed code to GitHub
- [ ] Verified all files are on GitHub
- [ ] Updated `.github/workflows/ci-cd.yml` with your Docker Hub username
- [ ] Updated ArgoCD application files (optional)

### GitHub Secrets:
- [ ] Added `DOCKER_USERNAME` secret
- [ ] Added `DOCKER_PASSWORD` secret (or access token)

### CI/CD:
- [ ] Made a commit/push to trigger workflow
- [ ] Checked Actions tab - workflow is running
- [ ] Verified images pushed to Docker Hub

---

## 🎯 Summary - What You Should See

### On GitHub:

**Repository Page:**
- ✅ All your project files
- ✅ README.md visible
- ✅ `.github/workflows/ci-cd.yml` file

**Settings → Secrets:**
- ✅ `DOCKER_USERNAME` listed
- ✅ `DOCKER_PASSWORD` listed

**Actions Tab:**
- ✅ Workflow runs appearing
- ✅ Green checkmarks when successful
- ✅ Build logs showing progress

### On Docker Hub:

**Repositories:**
- ✅ 5 repositories created
- ✅ Images with `latest` tag
- ✅ Images with commit SHA tags

---

## 🆘 Troubleshooting

### "Repository not found" error
→ Check your GitHub username is correct in the remote URL

### "Authentication failed" when pushing
→ Use Personal Access Token instead of password

### Workflow fails at "Login to Docker Hub"
→ Check secrets are spelled correctly: `DOCKER_USERNAME` and `DOCKER_PASSWORD`

### No workflow runs appear
→ Make sure `.github/workflows/ci-cd.yml` file exists and is pushed

### Images not appearing on Docker Hub
→ Check workflow logs in Actions tab for errors

---

## ✅ You're Done!

Once you complete these steps:
- ✅ Your code is on GitHub
- ✅ CI/CD is configured
- ✅ Images are being built and pushed automatically
- ✅ Every push to `main` triggers deployment

**Your project is now fully set up with CI/CD!** 🚀

