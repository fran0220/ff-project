#!/usr/bin/env sh
# FF Bootstrap Installer - Minimal install for cold start (no Amp environment)
# For full installation, use: load ff-init (in Amp)
set -eu

FF_REPO="${FF_REPO:-fran0220/ff-project}"
FF_REF="${FF_REF:-main}"

log() { printf "%s\n" "$*"; }
die() { printf "Error: %s\n" "$*" >&2; exit 1; }

log "📦 FF Bootstrap Installer"
log ""

# Download templates
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t ff-install)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

log "⬇️  Downloading FF templates..."
TARBALL_URL="https://codeload.github.com/$FF_REPO/tar.gz/$FF_REF"
( cd "$TMP_DIR" && curl -fsSL "$TARBALL_URL" | tar -xz ) || die "Failed to download"

SRC_ROOT="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
TEMPLATES="$SRC_ROOT/templates"

# Get version
FF_VERSION="$(cat "$TEMPLATES/ff/VERSION" 2>/dev/null || echo "unknown")"

# Install ff-init skill (minimum needed to bootstrap)
log "📁 Installing ff-init skill..."
mkdir -p .agents/skills/ff-init
cp -r "$TEMPLATES/agents/skills/ff-init/"* .agents/skills/ff-init/

# Install basic .ff structure
log "📚 Installing .ff/ structure..."
mkdir -p .ff
[ -f "$TEMPLATES/ff/.gitignore" ] && cp "$TEMPLATES/ff/.gitignore" .ff/.gitignore

# Setup developer identity
if [ ! -f ".ff/.developer" ]; then
  name=""
  command -v git >/dev/null 2>&1 && name="$(git config --get user.name 2>/dev/null || true)"
  [ -z "$name" ] && name="${USER:-developer}"
  echo "$name" > .ff/.developer
  log "👤 Developer: $name"
fi

# Create minimal manifest
log "📋 Creating manifest..."
cat > .ff/manifest.json <<EOF
{
  "schema": 1,
  "ffVersion": "$FF_VERSION",
  "installedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updatedAt": "",
  "projectType": "unknown",
  "repo": "$FF_REPO",
  "ref": "$FF_REF",
  "bootstrapped": true
}
EOF

log ""
log "✨ FF Bootstrap complete! (v$FF_VERSION)"
log ""
log "Next steps:"
log "  1. Open Amp in this project"
log "  2. Run: load ff-init"
log "  3. This will complete the full installation"
log ""
log "Or for a quick start:"
log "  Run: load ff-start"
