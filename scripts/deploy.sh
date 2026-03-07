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
API="https://$CPANEL_HOST:2083/execute"
AUTH="Authorization: cpanel $CPANEL_USER:$CPANEL_TOKEN"
CURL="curl -s --max-time 30"

upload_file() {
  local remote_dir="$1"
  local file="$2"
  local field="${3:-file-1}"
  RESULT=$($CURL -X POST "$API/Fileman/upload_files" \
    -H "$AUTH" \
    -F "dir=$remote_dir" \
    -F "overwrite=1" \
    -F "$field=@$file")
  echo "$RESULT" | grep -q '"status":1' || { echo "✗ Failed uploading $file: $RESULT"; exit 1; }
  echo "  ✓ $(basename $file)"
}

mkdir_remote() {
  local path="$1"
  local name="$2"
  $CURL -X POST "$API/Fileman/mkdir" \
    -H "$AUTH" \
    --data-urlencode "path=/$path" \
    --data-urlencode "name=$name" > /dev/null || true
}

# ── 1. Build ──────────────────────────────────────────────────────────────────
if [ ! -d "dist" ]; then
  echo "→ Building..."
  npm run build
else
  echo "→ Skipping build (dist/ already exists)"
fi

# ── 2. Deploy frontend ────────────────────────────────────────────────────────
echo "→ Deploying frontend..."
mkdir_remote "$REMOTE_DIR" "assets"
upload_file "$REMOTE_DIR" "dist/index.html"

CSS_FILE=$(ls dist/assets/*.css | head -1)
JS_FILE=$(ls dist/assets/*.js | head -1)
RESULT=$($CURL -X POST "$API/Fileman/upload_files" \
  -H "$AUTH" \
  -F "dir=$REMOTE_DIR/assets" \
  -F "overwrite=1" \
  -F "file-1=@$CSS_FILE" \
  -F "file-2=@$JS_FILE")
echo "$RESULT" | grep -q '"status":1' || { echo "✗ Failed uploading assets: $RESULT"; exit 1; }
echo "  ✓ $(basename $CSS_FILE)"
echo "  ✓ $(basename $JS_FILE)"

# ── 3. Deploy API files ───────────────────────────────────────────────────────
echo "→ Deploying API..."
mkdir_remote "$API_REMOTE_DIR" "app"
mkdir_remote "$API_REMOTE_DIR/app" "routers"
mkdir_remote "$API_REMOTE_DIR" "tmp"

upload_file "$API_REMOTE_DIR" "api/passenger_wsgi.py"
upload_file "$API_REMOTE_DIR" "api/requirements.txt"

for f in api/app/*.py; do
  upload_file "$API_REMOTE_DIR/app" "$f"
done

for f in api/app/routers/*.py; do
  upload_file "$API_REMOTE_DIR/app/routers" "$f"
done

# ── 4. Write .env to API dir ──────────────────────────────────────────────────
echo "→ Writing API .env..."
cat > /tmp/api.env << EOF
DATABASE_URL=${DATABASE_URL}
SECRET_KEY=${SECRET_KEY}
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}
FRONTEND_URL=${FRONTEND_URL}
CORS_ORIGINS=${CORS_ORIGINS}
EOF
upload_file "$API_REMOTE_DIR" "/tmp/api.env"
# rename .env (upload as api.env, move to .env)
$CURL -X POST "$API/Fileman/rename" \
  -H "$AUTH" \
  --data-urlencode "destfile=.env" \
  --data-urlencode "op=rename" \
  --data-urlencode "sourcefiles=$API_REMOTE_DIR/api.env" > /dev/null || true

# ── 5. Restart Passenger app ──────────────────────────────────────────────────
echo "→ Restarting API..."
echo "" > /tmp/restart.txt
upload_file "$API_REMOTE_DIR/tmp" "/tmp/restart.txt"

echo ""
echo "✓ Frontend → https://webappblueprint.peder.mk"
echo "✓ API      → https://api.webappblueprint.peder.mk"
echo ""
echo "Note: if this is first deploy, install dependencies manually in cPanel:"
echo "  cPanel → Python App → $API_REMOTE_DIR → pip install -r requirements.txt"
