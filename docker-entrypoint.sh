#!/bin/sh
set -e

# Generate dynamic runtime env-config.js from environment variables
CONFIG_FILE="/usr/share/nginx/html/env-config.js"

echo "Injecting runtime environment variables into ${CONFIG_FILE}..."

cat <<EOF > "${CONFIG_FILE}"
window.__ENV__ = {
  APP_ENV: "${APP_ENV:-production}",
  APP_TITLE: "${APP_TITLE:-To-Do List Application}",
  API_BASE_URL: "${API_BASE_URL:-}",
  ENABLE_VOICE_COMMANDS: ${ENABLE_VOICE_COMMANDS:-true},
  VERSION: "${APP_VERSION:-1.0.0}"
};
EOF

# Ensure appropriate permissions
chmod 644 "${CONFIG_FILE}" 2>/dev/null || true

echo "Configuration generated successfully. Starting NGINX..."
exec "$@"

