#!/usr/bin/env bash
set -u

top_n=30
stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/developer-cache-audit-${stamp}"
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
  "$HOME/Library/Developer/Xcode/DerivedData"
  "$HOME/Library/Developer/Xcode/Archives"
  "$HOME/Library/Developer/CoreSimulator"
  "$HOME/Library/Caches/com.apple.dt.Xcode"
  "$HOME/Library/Caches/org.swift.swiftpm"
  "$HOME/Library/Caches/Homebrew"
  "$HOME/.npm"
  "$HOME/.cache/pip"
  "$HOME/.cache/uv"
  "$HOME/.cargo"
  "$HOME/.gradle"
  "$HOME/.platformio"
  "$HOME/go/pkg/mod"
)

section "Known developer paths"
for path in "${paths[@]}"; do
  [[ -e "$path" ]] || continue
  kb="$(du -skx "$path" 2>/dev/null | awk '{print $1}')"
  [[ -n "${kb:-}" ]] || kb=0
  printf '%8s  %s\n' "$(human_kb "$kb")" "$path"
done | sort -hr | tee -a "$summary"

section "Large files in developer paths"
for path in "${paths[@]}"; do
  [[ -d "$path" ]] || continue
  find "$path" -xdev -type f -size +500M -print 2>>"$report_dir/find-large.err"
done |
  while IFS= read -r file; do
    kb="$(du -skx "$file" 2>/dev/null | awk '{print $1}')"
    [[ -n "${kb:-}" ]] || kb=0
    printf '%8s  %s\n' "$(human_kb "$kb")" "$file"
  done |
  sort -hr |
  head -n "$top_n" | tee -a "$summary"

section "Project-local build folders under cwd"
find "${PWD:-.}" -xdev -type d \( -name node_modules -o -name .next -o -name dist -o -name build -o -name target -o -name .venv -o -name DerivedData \) -prune -print 2>>"$report_dir/find-project.err" |
  while IFS= read -r dir; do
    kb="$(du -skx "$dir" 2>/dev/null | awk '{print $1}')"
    [[ -n "${kb:-}" ]] || kb=0
    printf '%8s  %s\n' "$(human_kb "$kb")" "$dir"
  done |
  sort -hr |
  head -n "$top_n" | tee -a "$summary"

[[ -s "$report_dir/find-large.err" ]] && emit "large-file permission/errors: $report_dir/find-large.err"
[[ -s "$report_dir/find-project.err" ]] && emit "project permission/errors: $report_dir/find-project.err"

section "Report files"
emit "$report_dir"
emit "summary: $summary"
