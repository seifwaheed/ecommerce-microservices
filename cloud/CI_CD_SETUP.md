# CI/CD Setup Guide

## ✅ CI/CD Pipeline Status

**Status: Configured but needs GitHub Secrets**

The CI/CD pipeline is **fully implemented** in `.github/workflows/ci-cd.yml`. It will:
- ✅ Build Docker images for all services
- ✅ Push images to Docker Hub
- ✅ Deploy to Kubernetes cluster
- ✅ Run on every push to main branch

## 🔧 To Complete CI/CD Setup

### Step 1: Update Workflow File

Edit `.github/workflows/ci-cd.yml` and change:

```yaml
env:
  REGISTRY: docker.io
  IMAGE_PREFIX: yourusername  # ← Change this to your Docker Hub username
```

### Step 2: Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

1. **DOCKER_USERNAME**
   - Name: `DOCKER_USERNAME`
   - Value: Your Docker Hub username

2. **DOCKER_PASSWORD**
   - Name: `DOCKER_PASSWORD`
   - Value: Your Docker Hub password or access token
   - **Note**: Use an access token for better security (Docker Hub → Account Settings → Security → New Access Token)

3. **KUBECONFIG** (Optional - only if deploying to remote cluster)
   - Name: `KUBECONFIG`
   - Value: Base64 encoded kubeconfig file
   - To get: `cat ~/.kube/config | base64`

### Step 3: Update ArgoCD Applications (If Using GitOps)

Edit `argocd/applications/*.yaml` and update repository URL:

```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/cloud.git  # ← Your repo URL
```

### Step 4: Test CI/CD

1. **Commit and push** your changes:
   ```bash
   git add .
   git commit -m "Configure CI/CD"
   git push origin main
   ```

2. **Check GitHub Actions**:
   - Go to your repository on GitHub
   - Click "Actions" tab
   - You should see workflow running
   - Click on the workflow to see progress

3. **Verify**:
   - Check Docker Hub for new images
   - Check Kubernetes cluster for deployments

## 📋 CI/CD Workflow Details

### What It Does:

1. **On Push to Main**:
   - Builds all Docker images
   - Tags with `latest` and commit SHA
   - Pushes to Docker Hub
   - Updates Kubernetes manifests with new image tags
   - Deploys to cluster

2. **On Pull Request**:
   - Builds images (doesn't push)
   - Runs tests (if configured)
   - Validates configuration

### Workflow Steps:

```yaml
1. Checkout code
2. Set up Python
3. Install dependencies
4. Run tests (if any)
5. Set up Docker Buildx
6. Login to Docker Hub
7. Build and push Catalog Service
8. Build and push Cart Service
9. Build and push Order Service
10. Build and push Payment Service
11. Build and push Dashboard
12. Deploy to Kubernetes (if on main branch)
```

## 🚀 Quick Setup Commands

### For Local Testing (Without GitHub):

```powershell
# Build images locally
.\scripts\build-and-load-images.ps1

# Deploy manually
.\scripts\deploy-all.ps1
```

### For GitHub CI/CD:

1. Update `IMAGE_PREFIX` in workflow file
2. Add GitHub Secrets
3. Push to GitHub
4. Watch Actions tab

## ✅ Verification

### Check CI/CD is Working:

1. **GitHub Actions Tab**:
   - Should show workflow runs
   - Green checkmark = success
   - Red X = failure (check logs)

2. **Docker Hub**:
   - Go to https://hub.docker.com
   - Check your repositories
   - Should see: `yourusername/catalog-service`, etc.

3. **Kubernetes**:
   ```powershell
   kubectl get deployments -n ecommerce
   kubectl get pods -n ecommerce
   ```

## 🐛 Troubleshooting

### Workflow Fails at Docker Login

- Check `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets are correct
- Use Docker Hub access token instead of password

### Images Not Pushing

- Check Docker Hub rate limits
- Verify `IMAGE_PREFIX` matches your Docker Hub username

### Deployment Fails

- Check `KUBECONFIG` secret is correct (if using remote cluster)
- Verify cluster is accessible
- Check deployment logs in GitHub Actions

### Workflow Not Running

- Make sure workflow file is in `.github/workflows/`
- Check file is named `ci-cd.yml`
- Verify you're pushing to `main` or `master` branch

## 📝 Summary

**CI/CD Status**: ✅ **DONE** (needs GitHub secrets configuration)

- ✅ Workflow file created
- ✅ Build process configured
- ✅ Deployment process configured
- ⚠️ Needs GitHub secrets to work
- ⚠️ Needs Docker Hub credentials

**Time to complete**: ~5 minutes (just add secrets)

Everything else is ready! 🎉

