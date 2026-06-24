#!/usr/bin/env bash
set -u

stamp="$(date +%Y%m%d-%H%M%S)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"
report_dir="${tmp_root}/launch-agent-audit-${stamp}"
mkdir -p "$report_dir"
summary="$report_dir/summary.txt"

emit() { printf '%s\n' "$*" | tee -a "$summary"; }
section() { printf '\n## %s\n' "$1" | tee -a "$summary"; }

plist_roots=(
  "$HOME/Library/LaunchAgents"
  "/Library/LaunchAgents"
  "/Library/LaunchDaemons"
)

system_plist_roots=(
  "/System/Library/LaunchAgents"
  "/System/Library/LaunchDaemons"
)

plist_print() {
  local key="$1"
  local plist="$2"
  local out
  out="$(/usr/libexec/PlistBuddy -c "Print :$key" "$plist" 2>/dev/null || true)"
  case "$out" in
    ""|*"File Doesn't Exist"*)
      printf ''
      ;;
    *)
      printf '%s' "$out"
      ;;
  esac
}

section "Launch plist locations"
for root in "${plist_roots[@]}"; do
  [[ -d "$root" ]] || continue
  count="$(find "$root" -maxdepth 1 -name '*.plist' 2>/dev/null | wc -l | tr -d ' ')"
  printf '%4s  %s\n' "$count" "$root"
done | tee -a "$summary"

section "System launch plist counts"
for root in "${system_plist_roots[@]}"; do
  [[ -d "$root" ]] || continue
  count="$(find "$root" -maxdepth 1 -name '*.plist' 2>/dev/null | wc -l | tr -d ' ')"
  printf '%4s  %s\n' "$count" "$root"
done | tee -a "$summary"

section "Launch plists"
plist_tsv="$report_dir/launch-plists.tsv"
: >"$plist_tsv"
for root in "${plist_roots[@]}"; do
  [[ -d "$root" ]] || continue
  find "$root" -maxdepth 1 -name '*.plist' -print0 2>>"$report_dir/find.err" |
    while IFS= read -r -d '' plist; do
      label="$(plist_print Label "$plist")"
      program="$(plist_print Program "$plist")"
      run_at_load="$(plist_print RunAtLoad "$plist")"
      printf '%s\t%s\t%s\t%s\n' "$label" "$run_at_load" "$program" "$plist" >>"$plist_tsv"
    done
done

awk -F '\t' '{ printf "%-55s  RunAtLoad=%-5s  %s\n", ($1?$1:"-"), ($2?$2:"-"), $4 }' "$plist_tsv" |
  sed -n '1,120p' | tee -a "$summary"

section "User launchctl services"
if command -v launchctl >/dev/null 2>&1; then
  launchctl print "gui/$(id -u)" >"$report_dir/launchctl-gui.txt" 2>"$report_dir/launchctl-gui.err" || true
  awk '/^[[:space:]]*[0-9A-Za-z_.-]+ =>/ { print }' "$report_dir/launchctl-gui.txt" | sed -n '1,80p' | tee -a "$summary"
  emit "full launchctl output: $report_dir/launchctl-gui.txt"
fi

section "Login/background item clues"
for path in \
  "$HOME/Library/Application Support/com.apple.backgroundtaskmanagementagent" \
  "$HOME/Library/Preferences/com.apple.loginitems.plist" \
  "$HOME/Library/Preferences/com.apple.backgroundtaskmanagementagent.plist"
do
  [[ -e "$path" ]] && emit "$path"
done

[[ -s "$report_dir/find.err" ]] && emit "permission/errors saved: $report_dir/find.err"

section "Report files"
emit "$report_dir"
emit "summary: $summary"
