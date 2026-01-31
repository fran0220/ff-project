#!/usr/bin/env sh
set -eu

FF_REPO_DEFAULT="fran0220/ff-project"
FF_REF_DEFAULT="main"

BEGIN_MARKER="<!-- ff-project:begin -->"
END_MARKER="<!-- ff-project:end -->"

FORCE=0
VERBOSE=0
FF_REPO="${FF_REPO:-$FF_REPO_DEFAULT}"
FF_REF="${FF_REF:-$FF_REF_DEFAULT}"

usage() {
  cat <<EOF
FF installer

Usage:
  curl -fsSL https://raw.githubusercontent.com/$FF_REPO_DEFAULT/$FF_REF_DEFAULT/install.sh | sh
  curl -fsSL ... | sh -s -- [options]

Options:
  --force      Overwrite existing files
  --verbose    Show detailed output
  --ref <ref>  Git ref: tag/branch/sha (default: $FF_REF_DEFAULT)
EOF
}

log() { printf "%s\n" "$*"; }
vlog() { [ "$VERBOSE" -eq 1 ] && printf "  %s\n" "$*"; }
die() { printf "Error: %s\n" "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
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

ensure_dir() { [ -d "$1" ] || mkdir -p "$1"; }

copy_tree() {
  src="$1"; dest="$2"
  ensure_dir "$dest"
  find "$src" -type d | while IFS= read -r d; do
    rel="${d#$src/}"; [ "$rel" = "$d" ] && rel=""
    [ -n "$rel" ] && ensure_dir "$dest/$rel"
  done
  find "$src" -type f | while IFS= read -r f; do
    rel="${f#$src/}"; out="$dest/$rel"
    ensure_dir "$(dirname "$out")"
    if [ -f "$out" ] && [ "$FORCE" -ne 1 ]; then
      vlog "skip: $out"
    else
      cp -f "$f" "$out"
      vlog "write: $out"
    fi
  done
}

copy_file() {
  src="$1"; dest="$2"
  ensure_dir "$(dirname "$dest")"
  if [ -f "$dest" ] && [ "$FORCE" -ne 1 ]; then
    vlog "skip: $dest"
  else
    cp -f "$src" "$dest"
    vlog "write: $dest"
  fi
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

log "🚀 Installing FF into: $(pwd)"
[ "$FORCE" -eq 1 ] && log "   Mode: --force"

log "📁 Installing .agents/skills/"
ensure_dir ".agents"
copy_tree "$TEMPLATES/agents/skills" ".agents/skills"

log "📚 Installing .ff/spec/"
ensure_dir ".ff"
copy_tree "$TEMPLATES/ff/spec" ".ff/spec"

log "📄 Installing .ff/.gitignore"
[ -f "$TEMPLATES/ff/.gitignore" ] && copy_file "$TEMPLATES/ff/.gitignore" ".ff/.gitignore"

log "👤 Setting up .ff/.developer"
setup_developer

log "📝 Configuring AGENTS.md"
update_agents_md

log ""
log "✨ Done!"
log ""
log "Next: open Amp and run: load ff-start"
