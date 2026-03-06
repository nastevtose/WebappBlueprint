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
API="https://$CPANEL_HOST:2083/execute"
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
curl -s -X POST "$API/Fileman/mkdir" \
  -H "$AUTH" \
  --data-urlencode "path=/$REMOTE_DIR" \
  --data-urlencode "name=assets" > /dev/null

# ── 3. Upload root files ──────────────────────────────────────────────────────
echo "→ Uploading index.html..."
RESULT=$(curl -s -X POST "$API/Fileman/upload_files" \
  -H "$AUTH" \
  -F "dir=$REMOTE_DIR" \
  -F "file-1=@dist/index.html")
echo "$RESULT" | grep -q '"status":1' || { echo "✗ Failed: $RESULT"; exit 1; }
echo "  ✓ index.html"

# ── 4. Upload assets ──────────────────────────────────────────────────────────
echo "→ Uploading assets..."
CSS_FILE=$(ls dist/assets/*.css | head -1)
JS_FILE=$(ls dist/assets/*.js | head -1)

RESULT=$(curl -s -X POST "$API/Fileman/upload_files" \
  -H "$AUTH" \
  -F "dir=$REMOTE_DIR/assets" \
  -F "file-1=@$CSS_FILE" \
  -F "file-2=@$JS_FILE")
echo "$RESULT" | grep -q '"status":1' || { echo "✗ Failed: $RESULT"; exit 1; }
echo "  ✓ $(basename $CSS_FILE)"
echo "  ✓ $(basename $JS_FILE)"

echo ""
echo "✓ Deployed to https://webappblueprint.peder.mk"
