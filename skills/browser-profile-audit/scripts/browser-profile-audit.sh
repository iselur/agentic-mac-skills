#!/usr/bin/env bash
set -u

usage() {
  cat <<'EOF'
Usage: browser-profile-audit.sh [--top N] [--min-mb N]

Read-only disk usage audit for browser profiles/caches on macOS.

Options:
  --top N      Rows to show per table. Default: 25.
  --min-mb N   Minimum large browser file size. Default: 250.
  -h, --help   Show this help.

This script reports paths and sizes only. It does not read browsing history contents.
EOF
}

top_n=25
min_mb=250
while [[ $# -gt 0 ]]; do
  case "$1" in
    --top) top_n="${2:-}"; shift 2 ;;
    --min-mb) min_mb="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done
case "$top_n" in ''|*[!0-9]*) echo "--top must be a positive integer" >&2; exit 2 ;; esac
case "$min_mb" in ''|*[!0-9]*) echo "--min-mb must be a positive integer" >&2; exit 2 ;; esac

stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/browser-profile-audit-${stamp}"
mkdir -p "$report_dir"
summary="$report_dir/summary.txt"

emit() { printf '%s\n' "$*" | tee -a "$summary"; }
section() { printf '\n## %s\n' "$1" | tee -a "$summary"; }
human_kb() {
  awk -v kb="$1" 'BEGIN {
    bytes = kb * 1024
    split("B KB MB GB TB", unit, " ")
    i = 1
    while (bytes >= 1024 && i < 5) { bytes /= 1024; i++ }
    if (i <= 2) printf "%.0f%s", bytes, unit[i]
    else printf "%.1f%s", bytes, unit[i]
  }'
}

paths=(
  "$HOME/Library/Application Support/Google/Chrome"
  "$HOME/Library/Caches/Google/Chrome"
  "$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
  "$HOME/Library/Caches/BraveSoftware/Brave-Browser"
  "$HOME/Library/Application Support/Microsoft Edge"
  "$HOME/Library/Caches/Microsoft Edge"
  "$HOME/Library/Application Support/Firefox"
  "$HOME/Library/Caches/Firefox"
  "$HOME/Library/Safari"
  "$HOME/Library/Containers/com.apple.Safari"
)

section "Known browser paths"
for path in "${paths[@]}"; do
  [[ -e "$path" ]] || continue
  kb="$(du -skx "$path" 2>/dev/null | awk '{print $1}')"
  [[ -n "${kb:-}" ]] || kb=0
  printf '%8s  %s\n' "$(human_kb "$kb")" "$path"
done | sort -hr | tee -a "$summary"

top_du() {
  local label="$1"
  local path="$2"
  [[ -d "$path" ]] || return 0
  section "$label"
  du -xkd 1 "$path" >"$report_dir/$(echo "$label" | tr ' /' '__').tsv" 2>/dev/null
  sort -nr "$report_dir/$(echo "$label" | tr ' /' '__').tsv" |
    head -n "$top_n" |
    while IFS=$'\t' read -r kb item; do
      printf '%8s  %s\n' "$(human_kb "$kb")" "$item"
    done | tee -a "$summary"
}

top_du "Chrome support" "$HOME/Library/Application Support/Google/Chrome"
top_du "Chrome cache" "$HOME/Library/Caches/Google/Chrome"
top_du "Safari container" "$HOME/Library/Containers/com.apple.Safari"
top_du "Firefox support" "$HOME/Library/Application Support/Firefox"

section "Large browser files"
min_size="+${min_mb}M"
for path in "${paths[@]}"; do
  [[ -d "$path" ]] || continue
  find "$path" -xdev -type f -size "$min_size" -print 2>>"$report_dir/find.err"
done |
  while IFS= read -r file; do
    kb="$(du -skx "$file" 2>/dev/null | awk '{print $1}')"
    [[ -n "${kb:-}" ]] || kb=0
    printf '%8s  %s\n' "$(human_kb "$kb")" "$file"
  done |
  sort -hr |
  head -n "$top_n" | tee -a "$summary"

[[ -s "$report_dir/find.err" ]] && emit "permission/errors saved: $report_dir/find.err"

section "Report files"
emit "$report_dir"
emit "summary: $summary"
