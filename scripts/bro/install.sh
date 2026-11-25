#!/bin/bash
# Installs the built app as /Applications/Bro-wser.app: quits it, swaps the app, reopens it. Its data is not touched.
# Erbin browses in Bro, so ask him before running this unless he just asked for the change.
# `install.sh claude` installs Bro-claude (built with `build.sh claude`) as /Applications/Bro-claude.app.
# Copies under an older name (Bro.app, Bro for Claude.app) go to the Trash; the data stays, it is keyed by app id.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2
case "${1:-bro}" in
  bro) name=Bro-wser; old=(Bro); id=is.erbin.ardia; derived=build ;;
  claude) name=Bro-claude; old=("Bro for Claude"); id=is.erbin.ardia.claude; derived=build-claude ;;
  *) echo "usage: install.sh [bro|claude]"; exit 2 ;;
esac
dest="/Applications/$name.app"
app="$PWD/apps/browser/$derived/Build/Products/Release/Ardia.app"
[ -d "$app" ] || { echo "No build yet: run scripts/bro/build.sh ${1:-bro}"; exit 1; }
codesign -v "$app" || { echo "The built app's signature doesn't verify; not installing."; exit 1; }
scripts/bro/check-tweaks.sh || { echo "A tweak is missing; not installing."; exit 1; }
scripts/bro/cli-patch.sh || echo "Could not patch the ardia command (see scripts/bro/cli-patch.sh); installing Bro anyway."
osascript -e "tell application id \"$id\" to quit" >/dev/null 2>&1
still_running() { pgrep -f "$dest/Contents/MacOS/" >/dev/null && return 0; for o in "${old[@]}"; do pgrep -f "/Applications/$o.app/Contents/MacOS/" >/dev/null && return 0; done; return 1; }
for _ in $(seq 1 60); do still_running || break; sleep 0.5; done
still_running && { echo "$name is still running; not installing."; exit 1; }
for o in "${old[@]}"; do  # the same app under an older name
  [ -d "/Applications/$o.app" ] && osascript -e "tell application \"Finder\" to delete (POSIX file \"/Applications/$o.app\")" >/dev/null 2>&1
done
if [ -d "$dest" ]; then
  osascript -e "tell application \"Finder\" to delete (POSIX file \"$dest\")" >/dev/null 2>&1
fi
[ -e "$dest" ] && { echo "Couldn't move the old $name.app to the Trash; not installing."; exit 1; }
ditto "$app" "$dest" && scripts/bro/adhoc-sign.sh "$dest" >/dev/null && codesign -v "$dest" || { echo "Install failed."; exit 1; }  # ad hoc: never expires
# The build product has the same app id as the installed Bro; left registered, macOS can show its icon (an older
# one, from the icon cache) for Bro in the Dock. Unregister it and register only the installed app.
lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
$lsregister -u "$app" >/dev/null 2>&1
# Old copies moved to the Trash by earlier installs stay registered too; the Dock can show any of their icons.
$lsregister -dump 2>/dev/null | awk -v id="$id" '/^path:/{sub(/^path: */,""); sub(/ \(0x[0-9a-f]+\)$/,""); p=$0} $0 ~ "identifier:.*" id "$"{print p}' \
  | grep -F "/.Trash/" | while IFS= read -r old; do $lsregister -u "$old" >/dev/null 2>&1; done
# ditto keeps the build folder's old date, and macOS keys its icon cache on it: bump it so a new icon shows.
touch "$dest" "$dest/Contents" "$dest/Contents/Info.plist"
$lsregister -f "$dest"
rm -f "$(getconf DARWIN_USER_CACHE_DIR)com.apple.dock.iconcache"
killall Dock 2>/dev/null || true
env -u ARDIA_DATA_DIR open -a "$dest"  # a shell's ARDIA_DATA_DIR would point the app at the other app's data
echo "Installed and reopened $name ($(git log --oneline -1 | cut -c1-60))."
