#!/usr/bin/env bash
# StrideGuard — GitHub/GitLab import script
# Run this once after cloning or unzipping to push to your own remote.
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh https://github.com/YOUR_USERNAME/strideguard.git

set -e

REMOTE=${1:-""}

echo ""
echo "  StrideGuard setup"
echo "  ================="
echo ""

# Init git if needed
if [ ! -d ".git" ]; then
  git init
  git branch -M main
  echo "  git repo initialized"
else
  echo "  git repo already exists, skipping init"
fi

# Set up .gitignore
cat > .gitignore << 'EOF'
.DS_Store
*.swp
*.swo
__pycache__/
*.pyc
.env
.env.*
node_modules/
EOF

# Stage everything
git add .

# Initial commit
if git diff --cached --quiet; then
  echo "  nothing to commit"
else
  git commit -m "feat: initial StrideGuard threat modeling agent

AI-powered STRIDE threat modeling agent for the GitLab Duo Agent Platform.

- Auto-triggers on MR open/update and needs-threat-model label
- Analyzes diffs against all 6 STRIDE categories
- Creates labeled GitLab issues per threat with severity, CWE, remediation
- Posts summary table as MR comment
- Auto-closes resolved threats on re-run

See README.md for full installation instructions."
  echo "  initial commit created"
fi

# Remote setup
if [ -n "$REMOTE" ]; then
  if git remote get-url origin &>/dev/null; then
    git remote set-url origin "$REMOTE"
    echo "  remote 'origin' updated to $REMOTE"
  else
    git remote add origin "$REMOTE"
    echo "  remote 'origin' set to $REMOTE"
  fi

  echo ""
  echo "  Pushing to remote..."
  git branch -M main
  git push -u origin main
  echo ""
  echo "  Done! Repo is live at: $REMOTE"
else
  echo ""
  echo "  No remote URL provided. To push to GitHub:"
  echo ""
  echo "    1. Create a new repo at https://github.com/new"
  echo "    2. Run: ./setup.sh https://github.com/YOUR_USERNAME/strideguard.git"
  echo ""
  echo "  Or manually:"
  echo "    git remote add origin <your-repo-url>"
  echo "    git branch -M main"
  echo "    git push -u origin main"
fi

echo ""
