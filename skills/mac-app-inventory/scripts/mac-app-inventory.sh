#!/usr/bin/env bash
set -u

usage() {
  cat <<'EOF'
Usage: mac-app-inventory.sh [--top N]

Read-only inventory of installed Mac apps and app-related disk usage.

Options:
  --top N      Rows to show per table. Default: 30.
  -h, --help   Show this help.

This script never deletes apps or app data.
EOF
}

top_n=30
while [[ $# -gt 0 ]]; do
  case "$1" in
    --top)
      top_n="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$top_n" in ''|*[!0-9]*) echo "--top must be a positive integer" >&2; exit 2 ;; esac

stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/mac-app-inventory-${stamp}"
mkdir -p "$report_dir"
summary="$report_dir/summary.txt"

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

emit() { printf '%s\n' "$*" | tee -a "$summary"; }
section() { printf '\n## %s\n' "$1" | tee -a "$summary"; }
plist_raw() {
  local key="$1"
  local app="$2"
  local out
  [[ -f "$app/Contents/Info.plist" ]] || return 0
  out="$(/usr/libexec/PlistBuddy -c "Print :$key" "$app/Contents/Info.plist" 2>/dev/null || true)"
  case "$out" in
    "")
      printf ''
      ;;
    *)
      printf '%s' "$out"
      ;;
  esac
}

app_roots=(
  "/Applications"
  "$HOME/Applications"
)

apps_tsv="$report_dir/apps.tsv"
: >"$apps_tsv"

for root in "${app_roots[@]}"; do
  [[ -d "$root" ]] || continue
  find "$root" -maxdepth 2 -type d -name '*.app' ! -name '.*' -print0 2>>"$report_dir/find-apps.err" |
    while IFS= read -r -d '' app; do
      kb="$(du -skx "$app" 2>/dev/null | awk '{print $1}')"
      [[ -n "${kb:-}" ]] || kb=0
      bundle_id="$(plist_raw CFBundleIdentifier "$app")"
      version="$(plist_raw CFBundleShortVersionString "$app")"
      [[ -n "$version" ]] || version="$(plist_raw CFBundleVersion "$app")"
      printf '%s\t%s\t%s\t%s\t%s\n' "$kb" "$(basename "$app")" "$bundle_id" "$version" "$app" >>"$apps_tsv"
    done
done

section "Largest app bundles"
sort -nr "$apps_tsv" |
  head -n "$top_n" |
  while IFS=$'\t' read -r kb name bundle_id version app; do
    printf '%8s  %-40s  %s\n' "$(human_kb "$kb")" "$name" "$app"
  done | tee -a "$summary"

section "App metadata"
sort -k2 "$apps_tsv" |
  head -n "$top_n" |
  while IFS=$'\t' read -r kb name bundle_id version app; do
    printf '%-40s  version=%s  bundle=%s\n' "$name" "${version:-unknown}" "${bundle_id:-unknown}"
  done | tee -a "$summary"

top_du() {
  local label="$1"
  local path="$2"
  local depth="$3"
  local outfile="$4"

  section "$label"
  if [[ ! -d "$path" ]]; then
    emit "missing: $path"
    return 0
  fi
  du -xkd "$depth" "$path" >"$outfile" 2>"$outfile.err"
  sort -nr "$outfile" |
    head -n "$top_n" |
    while IFS=$'\t' read -r kb item; do
      [[ -n "${kb:-}" && -n "${item:-}" ]] || continue
      printf '%8s  %s\n' "$(human_kb "$kb")" "$item"
    done | tee -a "$summary"
  [[ -s "$outfile.err" ]] && emit "permission/errors saved: $outfile.err"
}

top_du "Large app-support folders" "$HOME/Library/Application Support" 1 "$report_dir/application-support.tsv"
top_du "Large cache folders" "$HOME/Library/Caches" 1 "$report_dir/caches.tsv"
top_du "Large container folders" "$HOME/Library/Containers" 1 "$report_dir/containers.tsv"
top_du "Large group-container folders" "$HOME/Library/Group Containers" 1 "$report_dir/group-containers.tsv"

if [[ -s "$report_dir/find-apps.err" ]]; then
  section "Permission/errors"
  emit "$report_dir/find-apps.err"
fi

section "Report files"
emit "$report_dir"
emit "summary: $summary"
