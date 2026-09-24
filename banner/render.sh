#!/usr/bin/env bash
# Renders banner/banner.html with headless Chrome into profile/banner-light.png and
# profile/banner-dark.png (960x320 at 2x). The dark one has a transparent ground, so it sits on any
# of GitHub's dark themes. Needs network access for the Google Fonts the page imports.
set -euo pipefail
cd "$(dirname "$0")/.."
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
# Chrome runs with a throwaway profile and is stopped once the PNG is written: some versions keep running after
# --screenshot, and without --user-data-dir it would share your own profile.
render() {
  local profile out="$PWD/profile/$1"
  profile=$(mktemp -d)
  rm -f "$out"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --no-first-run --user-data-dir="$profile" \
    --window-size=960,320 --force-device-scale-factor=2 --default-background-color=00000000 \
    --virtual-time-budget=8000 --screenshot="$out" "file://$PWD/banner/banner.html$2" > /dev/null 2>&1 &
  local pid=$!
  for _ in $(seq 1 120); do
    [[ -s $out ]] && break
    kill -0 "$pid" 2> /dev/null || break
    sleep 0.25
  done
  sleep 0.5
  kill "$pid" 2> /dev/null || true
  wait "$pid" 2> /dev/null || true
  rm -rf "$profile"
  [[ -s $out ]] || { echo "no image written for $1" >&2; exit 1; }
  echo "rendered profile/$1 (1920x640)"
}
render banner-light.png ""
render banner-dark.png "#dark"
