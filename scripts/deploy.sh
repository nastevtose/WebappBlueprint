#!/bin/bash
set -euo pipefail

# Load .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

CPANEL_TOKEN="${GG_API_TOKEN}"
CPANEL_HOST="${CPANEL_HOST}"
CPANEL_USER="${CPANEL_USER}"
REMOTE_DIR="${CPANEL_REMOTE_DIR:-public_html/apps/WebAppBlueprint}"
API_REMOTE_DIR="${CPANEL_API_DIR:-api_app}"
VENV_PATH="${CPANEL_VENV_PATH:-virtualenv/${API_REMOTE_DIR}/3.12}"
SSH_PORT="${SSH_PORT:-22}"
SSH_CONN="${CPANEL_USER}@${CPANEL_HOST}"
CPANEL_API="https://$CPANEL_HOST:2083/execute"
AUTH="Authorization: cpanel $CPANEL_USER:$CPANEL_TOKEN"

# ── 1. Build (skip if dist/ already exists, e.g. in CI) ──────────────────────
if [ ! -d "dist" ]; then
  echo "→ Building..."
  npm run build
else
  echo "→ Skipping build (dist/ already exists)"
fi

# ── 2. Ensure remote directories exist ───────────────────────────────────────
echo "→ Creating remote directories..."
curl -s -X POST "$CPANEL_API/Fileman/mkdir" \
  -H "$AUTH" \
  --data-urlencode "path=/$REMOTE_DIR" \
  --data-urlencode "name=assets" > /dev/null

# ── 3. Upload frontend root files ─────────────────────────────────────────────
echo "→ Uploading index.html..."
RESULT=$(curl -s -X POST "$CPANEL_API/Fileman/upload_files" \
  -H "$AUTH" \
  -F "dir=$REMOTE_DIR" \
  -F "overwrite=1" \
  -F "file-1=@dist/index.html")
echo "$RESULT" | grep -q '"status":1' || { echo "✗ Failed: $RESULT"; exit 1; }
echo "  ✓ index.html"

# ── 4. Upload frontend assets ─────────────────────────────────────────────────
echo "→ Uploading assets..."
CSS_FILE=$(ls dist/assets/*.css | head -1)
JS_FILE=$(ls dist/assets/*.js | head -1)

RESULT=$(curl -s -X POST "$CPANEL_API/Fileman/upload_files" \
  -H "$AUTH" \
  -F "dir=$REMOTE_DIR/assets" \
  -F "overwrite=1" \
  -F "file-1=@$CSS_FILE" \
  -F "file-2=@$JS_FILE")
echo "$RESULT" | grep -q '"status":1' || { echo "✗ Failed: $RESULT"; exit 1; }
echo "  ✓ $(basename $CSS_FILE)"
echo "  ✓ $(basename $JS_FILE)"

# ── 5. Sync API files via SSH ─────────────────────────────────────────────────
echo "→ Syncing API files..."
SSH_OPTS="-p $SSH_PORT -o StrictHostKeyChecking=no -o BatchMode=yes"

rsync -az \
  -e "ssh $SSH_OPTS" \
  api/app \
  api/passenger_wsgi.py \
  api/requirements.txt \
  "$SSH_CONN:~/$API_REMOTE_DIR/"
echo "  ✓ API files synced"

# ── 6. Install dependencies & restart app ─────────────────────────────────────
echo "→ Installing dependencies & restarting..."
ssh $SSH_OPTS "$SSH_CONN" bash << EOF
  set -e
  source ~/$VENV_PATH/bin/activate
  pip install -q --upgrade pip
  pip install -q -r ~/$API_REMOTE_DIR/requirements.txt
  mkdir -p ~/$API_REMOTE_DIR/tmp
  touch ~/$API_REMOTE_DIR/tmp/restart.txt
  echo "  ✓ Dependencies installed"
  echo "  ✓ App restarted"
EOF

echo ""
echo "✓ Frontend deployed to https://webappblueprint.peder.mk"
echo "✓ API deployed to https://api.webappblueprint.peder.mk"
