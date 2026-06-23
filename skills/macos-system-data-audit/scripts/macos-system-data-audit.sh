#!/usr/bin/env bash
set -u

usage() {
  cat <<'EOF'
Usage: macos-system-data-audit.sh [--top N] [--min-gb N] [--full]

Read-only macOS disk accounting for "System Data" investigations.

Options:
  --top N      Rows to show per size table. Default: 25.
  --min-gb N   Minimum file size for large-file search. Default: 5.
  --full       Also search the whole Data volume for large files and VM images.
  -h, --help   Show this help.

Notes:
  - This script never deletes files.
  - For accurate results, run it from Terminal/Codex with Full Disk Access.
EOF
}

top_n=25
min_gb=5
full_scan=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --top)
      top_n="${2:-}"
      shift 2
      ;;
    --min-gb)
      min_gb="${2:-}"
      shift 2
      ;;
    --full)
      full_scan=1
      shift
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

case "$top_n" in
  ''|*[!0-9]*)
    echo "--top must be a positive integer" >&2
    exit 2
    ;;
esac

case "$min_gb" in
  ''|*[!0-9]*)
    echo "--min-gb must be a positive integer" >&2
    exit 2
    ;;
esac

DATA_VOLUME="/System/Volumes/Data"
HOME_DIR="${HOME:-/Users/$(id -un)}"
stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/macos-system-data-audit-${stamp}"
mkdir -p "$report_dir"
summary="$report_dir/summary.txt"

human_kb() {
  awk -v kb="$1" 'BEGIN {
    bytes = kb * 1024
    split("B KB MB GB TB PB", unit, " ")
    i = 1
    while (bytes >= 1024 && i < 6) { bytes /= 1024; i++ }
    if (i <= 2) printf "%.0f%s", bytes, unit[i]
    else printf "%.1f%s", bytes, unit[i]
  }'
}

emit() {
  printf '%s\n' "$*" | tee -a "$summary"
}

section() {
  {
    printf '\n## %s\n' "$1"
  } | tee -a "$summary"
}

du_kb() {
  local path="$1"
  du -skx "$path" 2>/dev/null | awk '{print $1}'
}

top_du() {
  local label="$1"
  local path="$2"
  local depth="$3"
  local outfile="$4"
  local errfile="${outfile}.err"

  section "$label"
  if [[ ! -e "$path" ]]; then
    emit "missing: $path"
    return 0
  fi

  du -xkd "$depth" "$path" >"$outfile" 2>"$errfile"
  sort -nr "$outfile" | head -n "$top_n" | while IFS=$'\t' read -r kb item; do
    [[ -n "${kb:-}" && -n "${item:-}" ]] || continue
    printf '%8s  %s\n' "$(human_kb "$kb")" "$item"
  done | tee -a "$summary"

  if [[ -s "$errfile" ]]; then
    emit "permission/errors saved: $errfile"
  fi
}

exact_sizes() {
  local outfile="$report_dir/exact-suspects.tsv"
  : >"$outfile"
  for path in "$@"; do
    if [[ -e "$path" ]]; then
      du -skx "$path" 2>/dev/null >>"$outfile"
    fi
  done

  section "Known high-signal suspects"
  if [[ -s "$outfile" ]]; then
    sort -nr "$outfile" | while IFS=$'\t' read -r kb item; do
      [[ -n "${kb:-}" && -n "${item:-}" ]] || continue
      printf '%8s  %s\n' "$(human_kb "$kb")" "$item"
    done | tee -a "$summary"
  else
    emit "No known suspect paths found."
  fi
}

find_large_files() {
  local label="$1"
  local outfile="$2"
  shift 2
  local min_size="+${min_gb}G"

  section "$label"
  : >"$outfile"
  for root in "$@"; do
    [[ -e "$root" ]] || continue
    find "$root" -xdev -type f -size "$min_size" -print 2>>"${outfile}.err" >>"$outfile"
  done

  if [[ -s "$outfile" ]]; then
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      local kb
      kb="$(du_kb "$file")"
      [[ -n "$kb" ]] || kb=0
      printf '%8s  %s\n' "$(human_kb "$kb")" "$file"
    done <"$outfile" | sort -hr | tee -a "$summary"
  else
    emit "No files >= ${min_gb}G found in searched roots."
  fi

  if [[ -s "${outfile}.err" ]]; then
    emit "permission/errors saved: ${outfile}.err"
  fi
}

find_vm_artifacts() {
  local outfile="$report_dir/vm-artifacts.txt"
  section "VM / Parallels artifacts"
  : >"$outfile"

  local roots=(
    "$HOME_DIR"
    "/Users/Shared"
    "$DATA_VOLUME/private/var"
  )

  for root in "${roots[@]}"; do
    [[ -e "$root" ]] || continue
    find "$root" -xdev \
      \( -iname '*.pvm' -o -iname '*.hdd' -o -iname '*.vmdk' -o -iname '*.vdi' -o -iname '*.qcow2' -o -iname '*.sparsebundle' \) \
      -print 2>>"${outfile}.err" >>"$outfile"
  done

  if [[ -s "$outfile" ]]; then
    sed -n '1,80p' "$outfile" | tee -a "$summary"
    local count
    count="$(wc -l <"$outfile" | tr -d ' ')"
    if [[ "$count" -gt 80 ]]; then
      emit "... truncated; full list: $outfile"
    fi
  else
    emit "No VM disk artifacts found in common locations."
  fi

  if [[ -s "${outfile}.err" ]]; then
    emit "permission/errors saved: ${outfile}.err"
  fi
}

section "APFS / volume overview"
df -h / "$DATA_VOLUME" /System/Volumes/Preboot /System/Volumes/VM 2>"$report_dir/df.err" | tee -a "$summary"

if command -v diskutil >/dev/null 2>&1; then
  diskutil info "$DATA_VOLUME" >"$report_dir/diskutil-data.txt" 2>"$report_dir/diskutil-data.err"
  awk '/Volume Used Space|Container Free Space|FileVault|Volume UUID|Mount Point/ { print }' "$report_dir/diskutil-data.txt" | tee -a "$summary"
fi

if command -v tmutil >/dev/null 2>&1; then
  section "Local snapshots"
  tmutil listlocalsnapshots / >"$report_dir/tmutil-snapshots.txt" 2>"$report_dir/tmutil-snapshots.err"
  if [[ -s "$report_dir/tmutil-snapshots.txt" ]]; then
    cat "$report_dir/tmutil-snapshots.txt" | tee -a "$summary"
  else
    emit "No tmutil local snapshots reported for /."
  fi
fi

top_du "Data volume top level" "$DATA_VOLUME" 1 "$report_dir/data-top.tsv"

df_used_kb="$(df -k "$DATA_VOLUME" 2>/dev/null | awk 'NR==2 {print $3}')"
du_used_kb="$(sort -nr "$report_dir/data-top.tsv" 2>/dev/null | awk -v path="$DATA_VOLUME" '$2 == path {print $1; exit}')"
if [[ -n "${df_used_kb:-}" && -n "${du_used_kb:-}" ]]; then
  section "Accounting gap"
  emit "df used: $(human_kb "$df_used_kb")"
  emit "du accounted: $(human_kb "$du_used_kb")"
  if [[ "$df_used_kb" -ge "$du_used_kb" ]]; then
    gap_kb=$((df_used_kb - du_used_kb))
    emit "unaccounted gap: $(human_kb "$gap_kb")"
    if [[ "$gap_kb" -gt 20971520 ]]; then
      emit "Gap is >20GB. If errors mention Permission denied, grant Full Disk Access to Terminal/Codex and restart it."
    fi
  else
    overlap_kb=$((du_used_kb - df_used_kb))
    emit "du exceeds df by: $(human_kb "$overlap_kb")"
    emit "This can happen with APFS clones/shared accounting; trust the per-directory ranking, not the raw sum."
  fi
fi

top_du "Home folder top level" "$HOME_DIR" 1 "$report_dir/home-top.tsv"
top_du "User Library top level" "$HOME_DIR/Library" 1 "$report_dir/library-top.tsv"
top_du "Group Containers, depth 2" "$HOME_DIR/Library/Group Containers" 2 "$report_dir/group-containers.tsv"
top_du "Application Support, depth 2" "$HOME_DIR/Library/Application Support" 2 "$report_dir/application-support.tsv"
top_du "Pictures, depth 2" "$HOME_DIR/Pictures" 2 "$report_dir/pictures.tsv"
top_du "Containers, depth 2" "$HOME_DIR/Library/Containers" 2 "$report_dir/containers.tsv"

exact_sizes \
  "$HOME_DIR/Library/Group Containers/group.com.apple.screencapture/ScreenRecordings" \
  "$HOME_DIR/Pictures/Photos Library.photoslibrary" \
  "$HOME_DIR/Library/Application Support/com.apple.wallpaper" \
  "$DATA_VOLUME/Library/Application Support/com.apple.idleassetsd" \
  "$HOME_DIR/Library/Parallels/Downloads" \
  "$HOME_DIR/Library/Parallels" \
  "$HOME_DIR/Parallels" \
  "/Users/Shared/Parallels" \
  "$HOME_DIR/Library/Group Containers/4C6364ACXT.com.parallels.Desktop" \
  "$HOME_DIR/Library/Group Containers/4C6364ACXT.com.parallels.toolbox" \
  "$HOME_DIR/Library/Group Containers/com.parallels.tools.statecontroller" \
  "$HOME_DIR/Library/iTunes" \
  "$HOME_DIR/Library/Mobile Documents" \
  "$HOME_DIR/Library/Group Containers/6N38VWS5BX.ru.keepcoder.Telegram" \
  "$HOME_DIR/Library/Group Containers/group.net.whatsapp.WhatsApp.shared" \
  "$HOME_DIR/Library/Caches" \
  "/System/Volumes/Preboot" \
  "/System/Volumes/VM" \
  "$DATA_VOLUME/private/var/vm"

find_large_files "Large files in home >= ${min_gb}G" "$report_dir/large-files-home.txt" "$HOME_DIR"
find_vm_artifacts

if [[ "$full_scan" -eq 1 ]]; then
  find_large_files "Large files in Data volume >= ${min_gb}G" "$report_dir/large-files-data.txt" "$DATA_VOLUME"
fi

section "Report files"
emit "$report_dir"
emit "summary: $summary"
