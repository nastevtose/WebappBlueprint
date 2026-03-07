#!/bin/bash
set -euo pipefail

# Load .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

CPANEL_HOST="${CPANEL_HOST}"
CPANEL_USER="${CPANEL_USER}"
REMOTE_DIR="${CPANEL_REMOTE_DIR:-public_html/apps/WebAppBlueprint}"
API_REMOTE_DIR="${CPANEL_API_DIR:-api_app}"
VENV_PATH="${CPANEL_VENV_PATH:-virtualenv/${API_REMOTE_DIR}/3.12}"
SSH_PORT="${SSH_PORT:-22}"
SSH_CONN="${CPANEL_USER}@${CPANEL_HOST}"
SSH_OPTS="-p $SSH_PORT -o StrictHostKeyChecking=no -o BatchMode=yes"

# ── 1. Build (skip if dist/ already exists, e.g. in CI) ──────────────────────
if [ ! -d "dist" ]; then
  echo "→ Building..."
  npm run build
else
  echo "→ Skipping build (dist/ already exists)"
fi

# ── 2. Deploy frontend via rsync ──────────────────────────────────────────────
echo "→ Deploying frontend..."
ssh $SSH_OPTS "$SSH_CONN" "mkdir -p ~/$REMOTE_DIR"
rsync -az --delete \
  -e "ssh $SSH_OPTS" \
  dist/ \
  "$SSH_CONN:~/$REMOTE_DIR/"
echo "  ✓ Frontend deployed"

# ── 3. Deploy API via rsync ───────────────────────────────────────────────────
echo "→ Deploying API..."
ssh $SSH_OPTS "$SSH_CONN" "mkdir -p ~/$API_REMOTE_DIR/app/routers"
rsync -az \
  -e "ssh $SSH_OPTS" \
  api/app \
  api/passenger_wsgi.py \
  api/requirements.txt \
  "$SSH_CONN:~/$API_REMOTE_DIR/"
echo "  ✓ API files synced"

# ── 4. Install dependencies & restart ────────────────────────────────────────
echo "→ Installing dependencies & restarting..."
ssh $SSH_OPTS "$SSH_CONN" bash << EOF
  set -e
  source ~/$VENV_PATH/bin/activate
  pip install -q --upgrade pip
  pip install -q -r ~/$API_REMOTE_DIR/requirements.txt
  mkdir -p ~/$API_REMOTE_DIR/tmp
  touch ~/$API_REMOTE_DIR/tmp/restart.txt
EOF
echo "  ✓ Dependencies installed & app restarted"

echo ""
echo "✓ Frontend → https://webappblueprint.peder.mk"
echo "✓ API      → https://api.webappblueprint.peder.mk"
