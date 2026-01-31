#!/usr/bin/env sh
# FF Library - Common functions for FF scripts

# Colors (if terminal supports)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

# Logging
log() { printf "%s\n" "$*"; }
log_info() { printf "${BLUE}ℹ${NC} %s\n" "$*"; }
log_ok() { printf "${GREEN}✓${NC} %s\n" "$*"; }
log_warn() { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
log_err() { printf "${RED}✗${NC} %s\n" "$*" >&2; }
die() { log_err "$*"; exit 1; }

# SHA256 hash (cross-platform)
sha256_file() {
  file="$1"
  [ -f "$file" ] || { echo ""; return 1; }
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | cut -d' ' -f1
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$file" | awk '{print $NF}'
  else
    die "No SHA256 tool available"
  fi
}

# ISO timestamp
now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Timestamp for backup dirs
timestamp_dir() {
  date +"%Y%m%d-%H%M%S"
}

# Ensure directory exists
ensure_dir() {
  [ -d "$1" ] || mkdir -p "$1"
}

# Atomic write (write to temp then move)
atomic_write() {
  dest="$1"
  content="$2"
  tmp="${dest}.tmp.$$"
  ensure_dir "$(dirname "$dest")"
  printf "%s" "$content" > "$tmp"
  mv -f "$tmp" "$dest"
}

# Backup a file
backup_file() {
  src="$1"
  backup_root="$2"
  [ -f "$src" ] || return 0
  rel_path="$src"
  backup_dest="$backup_root/$rel_path"
  ensure_dir "$(dirname "$backup_dest")"
  cp -f "$src" "$backup_dest"
}

# Download tarball from GitHub
download_tarball() {
  repo="$1"
  ref="$2"
  out_dir="$3"
  url="https://codeload.github.com/$repo/tar.gz/$ref"
  ensure_dir "$out_dir"
  curl -fsSL "$url" | tar -xz -C "$out_dir" || return 1
  # Return extracted root dir
  find "$out_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1
}

# Detect project type
detect_project_type() {
  # Frontend indicators
  has_frontend=0
  if [ -f "package.json" ]; then
    if [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ] || \
       [ -f "vite.config.js" ] || [ -f "vite.config.ts" ] || \
       [ -d "src/pages" ] || [ -d "src/app" ] || [ -d "app" ]; then
      has_frontend=1
    fi
  fi

  # Backend indicators
  has_backend=0
  if [ -f "go.mod" ] || [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] || \
     [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Cargo.toml" ] || [ -f "Gemfile" ] || \
     [ -d "src/server" ] || [ -d "server" ] || [ -d "api" ]; then
    has_backend=1
  fi

  if [ "$has_frontend" -eq 1 ] && [ "$has_backend" -eq 1 ]; then
    echo "fullstack"
  elif [ "$has_frontend" -eq 1 ]; then
    echo "frontend"
  elif [ "$has_backend" -eq 1 ]; then
    echo "backend"
  else
    echo "unknown"
  fi
}

# Read value from .ff/.version file
read_version_field() {
  field="$1"
  file=".ff/.version"
  [ -f "$file" ] || return 1
  grep "^${field}=" "$file" | cut -d'=' -f2-
}

# Write/update field in .ff/.version file
write_version_field() {
  field="$1"
  value="$2"
  file=".ff/.version"
  ensure_dir ".ff"
  if [ -f "$file" ] && grep -q "^${field}=" "$file"; then
    # Update existing field
    sed -i.bak "s|^${field}=.*|${field}=${value}|" "$file" && rm -f "${file}.bak"
  else
    # Append new field
    echo "${field}=${value}" >> "$file"
  fi
}
