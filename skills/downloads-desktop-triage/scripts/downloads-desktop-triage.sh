#!/usr/bin/env bash
set -u

usage() {
  cat <<'EOF'
Usage: downloads-desktop-triage.sh [--top N] [--min-mb N] [ROOT ...]

Read-only inventory of Downloads/Desktop clutter on macOS.

Options:
  --top N      Rows to show per table. Default: 30.
  --min-mb N   Minimum file size for large-file table. Default: 100.
  -h, --help   Show this help.

If no ROOT is supplied, scans ~/Downloads and ~/Desktop when present.
This script never deletes files.
EOF
}

top_n=30
min_mb=100
roots=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --top)
      top_n="${2:-}"
      shift 2
      ;;
    --min-mb)
      min_mb="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      roots+=("$1")
      shift
      ;;
  esac
done

case "$top_n" in ''|*[!0-9]*) echo "--top must be a positive integer" >&2; exit 2 ;; esac
case "$min_mb" in ''|*[!0-9]*) echo "--min-mb must be a positive integer" >&2; exit 2 ;; esac

if [[ "${#roots[@]}" -eq 0 ]]; then
  [[ -d "$HOME/Downloads" ]] && roots+=("$HOME/Downloads")
  [[ -d "$HOME/Desktop" ]] && roots+=("$HOME/Desktop")
fi

stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/downloads-desktop-triage-${stamp}"
mkdir -p "$report_dir"
summary="$report_dir/summary.txt"

human_bytes() {
  awk -v bytes="$1" 'BEGIN {
    split("B KB MB GB TB", unit, " ")
    i = 1
    while (bytes >= 1024 && i < 5) { bytes /= 1024; i++ }
    if (i <= 2) printf "%.0f%s", bytes, unit[i]
    else printf "%.1f%s", bytes, unit[i]
  }'
}

emit() { printf '%s\n' "$*" | tee -a "$summary"; }
section() { printf '\n## %s\n' "$1" | tee -a "$summary"; }
file_size() { stat -f '%z' "$1" 2>/dev/null || printf '0'; }

all_files="$report_dir/all-files.tsv"
: >"$all_files"

section "Roots"
for root in "${roots[@]}"; do
  if [[ -d "$root" ]]; then
    emit "$root"
    find "$root" -xdev \
      \( -type d \( -name .git -o -name node_modules -o -name .venv -o -name venv -o -name __pycache__ -o -name .ruff_cache -o -name DerivedData \) -prune \) -o \
      -type f -print0 2>>"$report_dir/find.err" |
      while IFS= read -r -d '' file; do
        size="$(file_size "$file")"
        mtime="$(stat -f '%Sm' -t '%Y-%m-%d' "$file" 2>/dev/null || printf '-')"
        printf '%s\t%s\t%s\t%s\n' "$size" "$mtime" "$(basename "$file")" "$file" >>"$all_files"
      done
  else
    emit "missing: $root"
  fi
done

section "Root sizes"
for root in "${roots[@]}"; do
  [[ -d "$root" ]] || continue
  kb="$(du -skx "$root" 2>/dev/null | awk '{print $1}')"
  [[ -n "${kb:-}" ]] || kb=0
  printf '%8s  %s\n' "$(human_bytes $((kb * 1024)))" "$root"
done | sort -hr | tee -a "$summary"

section "Large files"
min_bytes=$((min_mb * 1024 * 1024))
awk -F '\t' -v min="$min_bytes" '$1 >= min { print }' "$all_files" |
  sort -nr |
  head -n "$top_n" |
  while IFS=$'\t' read -r size mtime base file; do
    printf '%8s  %s  %s\n' "$(human_bytes "$size")" "$mtime" "$file"
  done | tee -a "$summary"

section "Installers, disk images, archives"
awk -F '\t' 'tolower($4) ~ /\.(dmg|pkg|mpkg|zip|rar|7z|tar|tgz|gz|bz2|xz|iso)$/ { print }' "$all_files" |
  sort -nr |
  head -n "$top_n" |
  while IFS=$'\t' read -r size mtime base file; do
    printf '%8s  %s  %s\n' "$(human_bytes "$size")" "$mtime" "$file"
  done | tee -a "$summary"

section "Screenshots and screen recordings"
awk -F '\t' 'tolower($3) ~ /^(screenshot|screen recording|screenrecording)/ || tolower($4) ~ /\.(mov|mp4)$/ { print }' "$all_files" |
  sort -nr |
  head -n "$top_n" |
  while IFS=$'\t' read -r size mtime base file; do
    printf '%8s  %s  %s\n' "$(human_bytes "$size")" "$mtime" "$file"
  done | tee -a "$summary"

section "Duplicate-looking basenames"
awk -F '\t' '$3 != "" { count[$3]++; total[$3]+=$1; example[$3]=$4 } END { for (b in count) if (count[b] > 1) printf "%012d\t%d\t%s\t%s\n", total[b], count[b], b, example[b] }' "$all_files" |
  sort -nr |
  head -n "$top_n" |
  while IFS=$'\t' read -r total count base example; do
    printf '%8s  %sx  %s  example: %s\n' "$(human_bytes "$total")" "$count" "$base" "$example"
  done | tee -a "$summary"

if [[ -s "$report_dir/find.err" ]]; then
  section "Permission/errors"
  emit "$report_dir/find.err"
fi

section "Report files"
emit "$report_dir"
emit "summary: $summary"
