# PyPI Setup Instructions for Jebasa

This guide will help you set up PyPI authentication for automatic releases via GitHub Actions.

## Step 1: Create PyPI Account (if needed)

1. Go to https://pypi.org/account/register/
2. Create your account with username `OCboy5`
3. Verify your email address

## Step 2: Create PyPI API Token

### For Production PyPI:
1. Log in to https://pypi.org
2. Go to Account Settings → API tokens
3. Click "Add API token"
4. **Token name:** `jebasa-github-actions`
5. **Scope:** Select "Entire account" (or "Project: jebasa" if restricting)
6. **Copy the token** (you'll only see it once!)

### For Test PyPI (Recommended for testing):
1. Log in to https://test.pypi.org
2. Go to Account Settings → API tokens
3. Click "Add API token"
4. **Token name:** `jebasa-test-github-actions`
5. **Scope:** Select "Entire account"
6. **Copy the token**

## Step 3: Add Secrets to GitHub Repository

1. Go to your GitHub repository: https://github.com/OCboy5/jebasa
2. Click **Settings** tab
3. Go to **Secrets and variables** → **Actions**
4. Click **"New repository secret"**

### Add Production PyPI Token:
- **Name:** `PYPI_API_TOKEN`
- **Value:** Paste your production PyPI API token

### Add Test PyPI Token:
- **Name:** `TEST_PYPI_API_TOKEN`
- **Value:** Paste your test PyPI API token

## Step 4: Test the Setup

### Test with Test PyPI (Recommended First):
1. Go to GitHub Actions tab
2. Trigger the "Test Release" workflow manually
3. Check if it uploads successfully to Test PyPI

### Check Test PyPI:
- Visit: https://test.pypi.org/project/jebasa/
- You should see your package there

### Test Installation:
```bash
pip install --index-url https://test.pypi.org/simple/ jebasa
```

## Step 5: Create Real Release

Once Test PyPI works:

1. **Create a git tag:**
```bash
git tag v0.1.0
git push origin v0.1.0
```

2. **This will trigger the Release workflow**
3. **Check GitHub Actions** to see if it uploads successfully

## Step 6: Verify Production Upload

1. Check https://pypi.org/project/jebasa/
2. Install from production PyPI:
```bash
pip install jebasa
```

## Troubleshooting

### Common Issues:

1. **"Invalid or non-existent authentication information"**
   - Double-check your API token is correct
   - Ensure the secret name matches exactly (`PYPI_API_TOKEN`)
   - Make sure the token has the right scope

2. **"Project name already exists"**
   - The name "jebasa" might be taken
   - You'll need to choose a different name or claim the name
   - Update `pyproject.toml` with a new name if needed

3. **Build fails**
   - Check the build logs in GitHub Actions
   - Ensure all dependencies are correctly specified
   - Run `python -m build` locally to test

4. **Version conflicts**
   - PyPI doesn't allow re-uploading the same version
   - Delete the tag and create a new version, or
   - Delete files from PyPI and re-upload

## Security Notes

- **Never commit API tokens** to your code
- **Use GitHub Secrets** for all sensitive information
- **Regularly rotate** your API tokens
- **Use scoped tokens** when possible (project-specific)

## Manual Upload (Backup Method)

If GitHub Actions fails, you can upload manually:

```bash
# Build the package
python -m build

# Upload to Test PyPI
twine upload --repository testpypi dist/*

# Upload to Production PyPI
twine upload dist/*
```

## Next Steps

After successful PyPI setup:
1. Update your README with installation instructions
2. Share your package with the community
3. Consider adding more tests and documentation
4. Set up automated version bumping

## Support

If you continue to have issues:
- Check PyPI documentation: https://pypi.org/help/
- Review GitHub Actions logs for detailed error messages
- Test locally first before pushing to GitHub