#!/usr/bin/env bash
set -u

usage() {
  cat <<'EOF'
Usage: image-batch-convert.sh [--execute] --out DIR [--format jpeg|png|heic] [--max-width N] FILE_OR_DIR ...

Dry-run-first image batch conversion using macOS sips.

Options:
  --execute      Actually write converted copies. Default is dry-run.
  --out DIR      Output directory. Required with --execute.
  --format FMT   Output format: jpeg, png, or heic. Default: jpeg.
  --max-width N  Resize longest edge to N pixels. Optional.
  -h, --help     Show this help.

Original files are never modified.
EOF
}

execute=0
out_dir=""
format="jpeg"
max_width=""
inputs=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) execute=1; shift ;;
    --out) out_dir="${2:-}"; shift 2 ;;
    --format) format="${2:-}"; shift 2 ;;
    --max-width) max_width="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) inputs+=("$1"); shift ;;
  esac
done

case "$format" in jpeg|png|heic) ;; *) echo "--format must be jpeg, png, or heic" >&2; exit 2 ;; esac
case "$max_width" in ""|*[!0-9]*) [[ -z "$max_width" ]] || { echo "--max-width must be a positive integer" >&2; exit 2; } ;; esac
if [[ "$execute" -eq 1 && -z "$out_dir" ]]; then echo "--out is required with --execute" >&2; exit 2; fi
if [[ "${#inputs[@]}" -eq 0 ]]; then usage >&2; exit 2; fi
command -v sips >/dev/null 2>&1 || { echo "sips is required on macOS" >&2; exit 2; }

ext="$format"
[[ "$format" = "jpeg" ]] && ext="jpg"

stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/image-batch-convert-${stamp}"
mkdir -p "$report_dir"
plan="$report_dir/plan.tsv"
: >"$plan"

collect_files() {
  local input="$1"
  if [[ -d "$input" ]]; then
    find "$input" -xdev -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' -o -iname '*.tif' -o -iname '*.tiff' \) -print0
  elif [[ -f "$input" ]]; then
    printf '%s\0' "$input"
  fi
}

for input in "${inputs[@]}"; do
  collect_files "$input" |
    while IFS= read -r -d '' file; do
      base="$(basename "$file")"
      name="${base%.*}"
      dest="${out_dir%/}/${name}.${ext}"
      if [[ -z "$out_dir" ]]; then dest="<OUT>/${name}.${ext}"; fi
      printf '%s\t%s\n' "$file" "$dest" >>"$plan"
    done
done

echo "Report: $report_dir"
echo
if [[ "$execute" -eq 0 ]]; then
  echo "Dry run. Planned conversions:"
  sed -n '1,80p' "$plan" | awk -F '\t' '{ printf "  %s -> %s\n", $1, $2 }'
  count="$(wc -l <"$plan" | tr -d ' ')"
  [[ "$count" -gt 80 ]] && echo "  ... truncated; full plan: $plan"
  exit 0
fi

mkdir -p "$out_dir"
while IFS=$'\t' read -r src dest; do
  if [[ -e "$dest" ]]; then
    echo "skip existing: $dest"
    continue
  fi
  if [[ -n "$max_width" ]]; then
    if ! sips -s format "$format" -Z "$max_width" "$src" --out "$dest" >/dev/null 2>>"$report_dir/sips.err"; then
      echo "failed: $src"
      continue
    fi
  else
    if ! sips -s format "$format" "$src" --out "$dest" >/dev/null 2>>"$report_dir/sips.err"; then
      echo "failed: $src"
      continue
    fi
  fi
  echo "wrote: $dest"
done <"$plan"

[[ -s "$report_dir/sips.err" ]] && echo "sips warnings/errors: $report_dir/sips.err"
