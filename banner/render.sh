#!/usr/bin/env bash
# Renders banner/banner.html with headless Chrome into profile/banner-light.png and
# profile/banner-dark.png (960x320 at 2x). The dark one has a transparent ground, so it sits on any
# of GitHub's dark themes. Needs network access for the Google Fonts the page imports.
set -euo pipefail
cd "$(dirname "$0")/.."
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
render() {
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --no-first-run --window-size=960,320 \
    --force-device-scale-factor=2 --default-background-color=00000000 --virtual-time-budget=8000 \
    --screenshot="$PWD/profile/$1" "file://$PWD/banner/banner.html$2" > /dev/null 2>&1
  echo "rendered profile/$1 (1920x640)"
}
render banner-light.png ""
render banner-dark.png "#dark"
