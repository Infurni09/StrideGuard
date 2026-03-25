#!/usr/bin/env bash
# StrideGuard — GitHub/GitLab import script
#
# Run this once after cloning or unzipping to initialize git and push to your remote.
#
# Usage:
#   cd strideguard
#   chmod +x setup.sh
#   ./setup.sh https://github.com/YOUR_USERNAME/strideguard.git

set -e

# Guard: ensure we are inside the strideguard directory
if [ ! -f "prompts/stride_analysis.md" ] || [ ! -f ".gitlab/agents/strideguard/config.yaml" ]; then
  echo ""
  echo "  Error: run this script from inside the strideguard/ directory."
  echo "  Example: cd strideguard && ./setup.sh"
  echo ""
  exit 1
fi

REMOTE="${1:-}"

echo ""
echo "  StrideGuard setup"
echo "  ================="
echo ""

# Init git if not already a repo
if [ ! -d ".git" ]; then
  git init
  git branch -M main
  echo "  git repo initialized (branch: main)"
else
  echo "  git repo already exists — skipping init"
fi

# Write .gitignore
cat > .gitignore << 'GITIGNORE_EOF'
.DS_Store
*.swp
*.swo
__pycache__/
*.pyc
.env
.env.*
node_modules/
GITIGNORE_EOF

echo "  .gitignore written"

# Stage everything
git add .

# Commit if there are staged changes
if git diff --cached --quiet; then
  echo "  nothing to commit — repo is already up to date"
else
  git commit -m "feat: initial StrideGuard threat modeling agent

AI-powered STRIDE threat modeling agent for the GitLab Duo Agent Platform.

Features:
- Auto-triggers on MR open/update and needs-threat-model label events
- Analyzes diffs against all 6 STRIDE categories
- Creates labeled GitLab issues per threat with severity, CWE, remediation
- Posts severity-sorted summary table as MR comment
- Auto-closes resolved threats on MR re-run (deduplication + cleanup)
- Pre-implementation threat modeling from epic/issue descriptions

See README.md for full installation instructions."
  echo "  initial commit created"
fi

# Remote setup and push
if [ -n "$REMOTE" ]; then
  if git remote get-url origin &>/dev/null 2>&1; then
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
  echo "  No remote URL provided."
  echo "  To push to GitHub, run:"
  echo ""
  echo "    ./setup.sh https://github.com/YOUR_USERNAME/strideguard.git"
  echo ""
  echo "  Or push manually:"
  echo "    git remote add origin <your-repo-url>"
  echo "    git branch -M main"
  echo "    git push -u origin main"
fi

echo ""
