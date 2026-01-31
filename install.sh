#!/usr/bin/env sh
# FF Installer - Install FF framework into your project
set -eu

FF_REPO_DEFAULT="fran0220/ff-project"
FF_REF_DEFAULT="main"

BEGIN_MARKER="<!-- ff-project:begin -->"
END_MARKER="<!-- ff-project:end -->"

FORCE=0
VERBOSE=0
PROJECT_TYPE=""
FF_REPO="${FF_REPO:-$FF_REPO_DEFAULT}"
FF_REF="${FF_REF:-$FF_REF_DEFAULT}"

usage() {
  cat <<EOF
FF Installer

Usage:
  curl -fsSL https://github.com/$FF_REPO_DEFAULT/raw/$FF_REF_DEFAULT/install.sh | sh
  curl -fsSL ... | sh -s -- [options]

Options:
  --force              Overwrite existing files
  --verbose            Show detailed output
  --type <type>        Project type: frontend|backend|fullstack|auto (default: auto)
  --ref <ref>          Git ref: tag/branch/sha (default: $FF_REF_DEFAULT)
EOF
}

log() { printf "%s\n" "$*"; }
vlog() { [ "$VERBOSE" -eq 1 ] && printf "  %s\n" "$*" || true; }
die() { printf "Error: %s\n" "$*" >&2; exit 1; }

# SHA256 hash (cross-platform)
sha256_file() {
  file="$1"
  [ -f "$file" ] || { echo ""; return 0; }
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | cut -d' ' -f1
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$file" | awk '{print $NF}'
  else
    echo ""
  fi
}

# Detect project type
detect_project_type() {
  has_frontend=0
  if [ -f "package.json" ]; then
    if [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ] || \
       [ -f "vite.config.js" ] || [ -f "vite.config.ts" ] || \
       [ -d "src/pages" ] || [ -d "src/app" ] || [ -d "app" ]; then
      has_frontend=1
    fi
  fi

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

while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
    --type) shift; PROJECT_TYPE="$1"; shift ;;
    --ref) shift; [ $# -gt 0 ] || die "--ref needs value"; FF_REF="$1"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t ff-install)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

TARBALL_URL="https://codeload.github.com/$FF_REPO/tar.gz/$FF_REF"
vlog "Downloading: $TARBALL_URL"

log "📦 Downloading FF..."
( cd "$TMP_DIR" && curl -fsSL "$TARBALL_URL" | tar -xz ) || die "Failed to download"

SRC_ROOT="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[ -n "${SRC_ROOT:-}" ] || die "Cannot find extracted root"

TEMPLATES="$SRC_ROOT/templates"
[ -d "$TEMPLATES/agents/skills" ] || die "Missing templates/agents/skills"
[ -d "$TEMPLATES/ff/spec" ] || die "Missing templates/ff/spec"

# Get version
FF_VERSION="$(cat "$TEMPLATES/ff/VERSION" 2>/dev/null || echo "unknown")"

ensure_dir() { [ -d "$1" ] || mkdir -p "$1"; }

# Hash file for tracking
HASH_FILE=".ff/.template-hashes"
HASH_TMP="$TMP_DIR/hashes.tmp"
touch "$HASH_TMP"

save_hash() {
  path="$1"
  hash="$2"
  echo "${path}:${hash}" >> "$HASH_TMP"
}

copy_tree() {
  src="$1"; dest="$2"; prefix="$3"
  ensure_dir "$dest"
  find "$src" -type d | while IFS= read -r d; do
    rel="${d#$src/}"; [ "$rel" = "$d" ] && rel=""
    [ -n "$rel" ] && ensure_dir "$dest/$rel"
  done
  find "$src" -type f | while IFS= read -r f; do
    rel="${f#$src/}"; out="$dest/$rel"
    full_rel="${prefix}${rel}"
    ensure_dir "$(dirname "$out")"
    
    new_hash="$(sha256_file "$f")"
    
    if [ -f "$out" ] && [ "$FORCE" -ne 1 ]; then
      vlog "skip: $out"
    else
      cp -f "$f" "$out"
      vlog "write: $out"
    fi
    
    # Always record hash for the template file
    save_hash "$full_rel" "$new_hash"
  done
}

copy_file() {
  src="$1"; dest="$2"; rel="$3"
  ensure_dir "$(dirname "$dest")"
  
  new_hash="$(sha256_file "$src")"
  
  if [ -f "$dest" ] && [ "$FORCE" -ne 1 ]; then
    vlog "skip: $dest"
  else
    cp -f "$src" "$dest"
    vlog "write: $dest"
  fi
  
  save_hash "$rel" "$new_hash"
}

setup_developer() {
  ensure_dir ".ff"
  [ -f ".ff/.developer" ] && { vlog "skip: .ff/.developer"; return 0; }
  name=""
  command -v git >/dev/null 2>&1 && name="$(git config --get user.name 2>/dev/null || true)"
  [ -z "$name" ] && name="${USER:-developer}"
  printf "%s" "$name" > ".ff/.developer"
  vlog "write: .ff/.developer ($name)"
}

setup_version() {
  ensure_dir ".ff"
  
  # Detect project type if not specified
  if [ -z "$PROJECT_TYPE" ] || [ "$PROJECT_TYPE" = "auto" ]; then
    PROJECT_TYPE="$(detect_project_type)"
  fi
  
  cat > ".ff/.version" <<EOF
schema=1
repo=$FF_REPO
ref=$FF_REF
ff_version=$FF_VERSION
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
project_type=$PROJECT_TYPE
EOF
  vlog "write: .ff/.version (v$FF_VERSION, type: $PROJECT_TYPE)"
}

update_agents_md() {
  managed_tmp="$TMP_DIR/managed_block.txt"
  {
    printf "%s\n" "$BEGIN_MARKER"
    cat "$TEMPLATES/AGENTS.md"
    printf "%s\n" "$END_MARKER"
  } > "$managed_tmp"

  if [ ! -f "AGENTS.md" ]; then
    cp -f "$managed_tmp" "AGENTS.md"
    vlog "create: AGENTS.md"
    return 0
  fi

  if grep -q "$BEGIN_MARKER" "AGENTS.md" && grep -q "$END_MARKER" "AGENTS.md"; then
    awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" -v block="$managed_tmp" '
      BEGIN { inblock=0 }
      $0==begin { while ((getline line < block) > 0) print line; close(block); inblock=1; next }
      inblock==1 && $0==end { inblock=0; next }
      inblock==0 { print }
    ' "AGENTS.md" > "$TMP_DIR/AGENTS.md.new" && mv "$TMP_DIR/AGENTS.md.new" "AGENTS.md"
    vlog "update: AGENTS.md (replaced block)"
  else
    printf "\n\n" >> "AGENTS.md"
    cat "$managed_tmp" >> "AGENTS.md"
    vlog "update: AGENTS.md (appended block)"
  fi
}

finalize_hashes() {
  ensure_dir ".ff"
  mv -f "$HASH_TMP" "$HASH_FILE"
  vlog "write: $HASH_FILE"
}

log "🚀 Installing FF into: $(pwd)"
[ "$FORCE" -eq 1 ] && log "   Mode: --force"

log "📁 Installing .agents/skills/"
ensure_dir ".agents"
copy_tree "$TEMPLATES/agents/skills" ".agents/skills" ".agents/skills/"

log "📚 Installing .ff/spec/"
ensure_dir ".ff"
copy_tree "$TEMPLATES/ff/spec" ".ff/spec" ".ff/spec/"

log "🔧 Installing .ff/bin/"
if [ -d "$TEMPLATES/ff/bin" ]; then
  copy_tree "$TEMPLATES/ff/bin" ".ff/bin" ".ff/bin/"
  # Make scripts executable
  find ".ff/bin" -type f -name "ff-*" -exec chmod +x {} \;
fi

log "📄 Installing .ff/.gitignore"
[ -f "$TEMPLATES/ff/.gitignore" ] && copy_file "$TEMPLATES/ff/.gitignore" ".ff/.gitignore" ".ff/.gitignore"

log "👤 Setting up .ff/.developer"
setup_developer

log "📋 Setting up .ff/.version"
setup_version

log "📝 Configuring AGENTS.md"
update_agents_md

log "🔒 Saving template hashes"
finalize_hashes

log ""
log "✨ Done! (v$FF_VERSION)"
log ""
log "Project type: $PROJECT_TYPE"
log ""
log "Next steps:"
log "  1. Open Amp and run: load ff-start"
log "  2. To update later: sh .ff/bin/ff-update"
