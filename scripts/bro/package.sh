#!/bin/bash
# Packages Bro-wser for anyone to download: builds it, signs it ad hoc and wraps it in a drag-to-install DMG.
#   scripts/bro/package.sh             build and package -> dist/Bro-wser-<version>-arm64.dmg
#   scripts/bro/package.sh --release   also publish it as a GitHub release (tag bro-<version>) on stackoverprof/bro-wser
#   scripts/bro/package.sh --skip-build  package the last build instead of building again
# The public build is signed ad hoc (like Runway), not with Erbin's development certificate: that certificate carries
# his Apple ID, and it wouldn't let the app past Gatekeeper on someone else's Mac anyway. Users run `xattr` once.
set -euo pipefail
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"

release=false; build=true
for arg in "$@"; do
  case "$arg" in
    --release) release=true ;;
    --skip-build) build=false ;;
    *) echo "usage: package.sh [--release] [--skip-build]"; exit 2 ;;
  esac
done

if $release; then
  [ "$(git rev-parse --abbrev-ref HEAD)" = bro-wser ] || { echo "Release from branch bro-wser."; exit 2; }
  [ -z "$(git status --porcelain -- apps packages scripts)" ] || { echo "Commit first: a release must match its source."; exit 2; }
fi

if $build; then
  scripts/bro/check-tweaks.sh
  app=$(scripts/bro/build.sh | tail -1)
else
  app="$root/apps/browser/build/Build/Products/Release/Ardia.app"
fi
[ -d "$app" ] || { echo "No built app at $app"; exit 1; }

version=$(plutil -extract CFBundleShortVersionString raw "$app/Contents/Info.plist")
arch=$(uname -m)
mkdir -p dist
dmg="dist/Bro-wser-$version-$arch.dmg"
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT

ditto "$app" "$staging/Bro-wser.app"
scripts/bro/adhoc-sign.sh "$staging/Bro-wser.app"  # no profile, no team entitlements, no certificate
ln -s /Applications "$staging/Applications"

rm -f "$dmg"
hdiutil create -volname "Bro-wser $version" -srcfolder "$staging" -format UDZO -ov "$dmg" >/dev/null
echo "Packaged $dmg ($(du -h "$dmg" | cut -f1))"

$release || exit 0
tag="bro-$version"
n=1
while git rev-parse -q --verify "refs/tags/$tag" >/dev/null || gh release view "$tag" -R stackoverprof/bro-wser >/dev/null 2>&1; do
  n=$((n + 1)); tag="bro-$version-$n"
done
git tag "$tag" && git push -q origin "$tag"
notes=$(mktemp)
{
  echo "Bro-wser $version, built on Ardia $version with Bro's tweaks (see the README)."
  echo
  echo "Install: open the DMG, drag Bro-wser into Applications, then once in Terminal:"
  echo
  echo '```sh'
  echo "xattr -dr com.apple.quarantine /Applications/Bro-wser.app"
  echo '```'
  echo
  echo "Apple Silicon, macOS 14 or newer. Bro-wser doesn't update itself: download the next release to update."
} > "$notes"
gh release create "$tag" "$dmg" -R stackoverprof/bro-wser --title "Bro-wser $version${n:+$([ "$n" -gt 1 ] && echo " ($n)")}" --notes-file "$notes" --latest
rm -f "$notes"
echo "Released $tag"
