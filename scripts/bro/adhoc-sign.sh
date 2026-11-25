#!/bin/bash
# Re-signs a built Bro app ad hoc, so it never expires. The Xcode build is signed with a free Apple Development
# profile, which macOS stops honouring after 7 days ("The application can't be opened"). Ad hoc has no profile and no
# expiry. It drops the profile and the entitlements tied to the Apple team (app id, keychain groups for Chromium's
# passkeys, get-task-allow), which an ad hoc app can't launch with; the device and privacy ones stay.
#   scripts/bro/adhoc-sign.sh <path/to/App.app>
set -euo pipefail
app="${1:?usage: adhoc-sign.sh <app>}"
rm -f "$app/Contents/embedded.provisionprofile"
# No hardened runtime: with an ad hoc signature it would refuse to load the app's own frameworks.
codesign --force --deep --sign - --preserve-metadata=entitlements "$app"
ents=$(mktemp)
codesign -d --entitlements :- "$app" 2>/dev/null > "$ents"
for key in com.apple.application-identifier com.apple.developer.team-identifier keychain-access-groups com.apple.security.get-task-allow; do
  /usr/libexec/PlistBuddy -c "Delete :$key" "$ents" 2>/dev/null || true
done
codesign --force --sign - --entitlements "$ents" "$app"
rm -f "$ents"
codesign --verify --deep --strict "$app"
if codesign -dv "$app" 2>&1 | grep -q "Authority=" || [ -n "$(find "$app" -name '*.provisionprofile')" ]; then
  echo "$app still carries a certificate or profile."; exit 1
fi
