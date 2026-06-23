#!/usr/bin/env bash
set -u

stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/backup-audit-${stamp}"
mkdir -p "$report_dir"
summary="$report_dir/summary.txt"

emit() { printf '%s\n' "$*" | tee -a "$summary"; }
section() { printf '\n## %s\n' "$1" | tee -a "$summary"; }

section "APFS overview"
df -h / /System/Volumes/Data /System/Volumes/Preboot /System/Volumes/VM 2>"$report_dir/df.err" | tee -a "$summary"

section "Time Machine"
if command -v tmutil >/dev/null 2>&1; then
  tmutil status >"$report_dir/tmutil-status.txt" 2>"$report_dir/tmutil-status.err" || true
  tmutil destinationinfo >"$report_dir/tmutil-destinations.txt" 2>"$report_dir/tmutil-destinations.err" || true
  tmutil latestbackup >"$report_dir/tmutil-latestbackup.txt" 2>"$report_dir/tmutil-latestbackup.err" || true

  emit "status: $report_dir/tmutil-status.txt"
  sed -n '1,40p' "$report_dir/tmutil-status.txt" | tee -a "$summary"
  emit "destinations: $report_dir/tmutil-destinations.txt"
  sed -n '1,80p' "$report_dir/tmutil-destinations.txt" | tee -a "$summary"
  if [[ -s "$report_dir/tmutil-latestbackup.txt" ]]; then
    emit "latest backup:"
    cat "$report_dir/tmutil-latestbackup.txt" | tee -a "$summary"
  fi
else
  emit "tmutil not found"
fi

section "Local snapshots"
if command -v tmutil >/dev/null 2>&1; then
  tmutil listlocalsnapshots / >"$report_dir/local-snapshots.txt" 2>"$report_dir/local-snapshots.err" || true
  if [[ -s "$report_dir/local-snapshots.txt" ]]; then
    cat "$report_dir/local-snapshots.txt" | tee -a "$summary"
  else
    emit "No local snapshots reported for /."
  fi
fi

section "Common backup-sized folders"
paths=(
  "$HOME/Backups.backupdb"
  "$HOME/Documents/Backups.backupdb"
  "$HOME/Library/Application Support/MobileSync/Backup"
  "$HOME/Library/Containers/com.apple.TimeMachine/Data"
  "/Volumes"
)

for path in "${paths[@]}"; do
  [[ -e "$path" ]] || continue
  du -skx "$path" 2>/dev/null
done |
  sort -nr |
  while IFS=$'\t' read -r kb path; do
    awk -v kb="$kb" -v path="$path" 'BEGIN {
      bytes = kb * 1024
      split("B KB MB GB TB", unit, " ")
      i = 1
      while (bytes >= 1024 && i < 5) { bytes /= 1024; i++ }
      printf "%8.1f%s  %s\n", bytes, unit[i], path
    }'
  done | tee -a "$summary"

section "Report files"
emit "$report_dir"
emit "summary: $summary"
