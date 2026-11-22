#!/bin/bash
# Checks that every tweak listed in FORK.md is still in the code. Run after merging Ardia in.
# Each line: a file, then a string that must still be in it. Exit 1 lists what went missing.
cd "$(dirname "$0")/../.." || exit 2
missing=0
check() { grep -qF -- "$2" "$1" 2>/dev/null || { echo "MISSING in $1: $2"; missing=1; }; }

B=apps/browser
check $B/macos/Ardia.xcodeproj/project.pbxproj 'BRO_APP_NAME = "Bro-wser";'
check $B/macos/Ardia-macOS/AppIcon.icon/icon.json '"image-name": "dots.png"'
check $B/macos/Ardia.xcodeproj/project.pbxproj 'PRODUCT_BUNDLE_IDENTIFIER = is.erbin.ardia;'
check $B/macos/Ardia.xcodeproj/project.pbxproj 'DEVELOPMENT_TEAM = B39983B5VG;'
grep -A1 '<key>SUFeedURL</key>' $B/macos/Ardia-macOS/Info.plist | grep -q '<string></string>' || { echo "MISSING: the updater feed must stay empty (Info.plist SUFeedURL)"; missing=1; }
grep -A1 '<key>SUEnableAutomaticChecks</key>' $B/macos/Ardia-macOS/Info.plist | grep -q '<false/>' || { echo "MISSING: automatic update checks must stay off (Info.plist)"; missing=1; }

check $B/src/lib/brand.ts 'text.replace(/\bArdia\b/g, appName)'
check $B/src/components/ui/Text.tsx 'brandDeep(rest.children)'
check $B/src/components/ui/Button.tsx 'brand(props.tooltip)'
check $B/src/platform/dialogs.ts 'Dialogs.confirm(brandDeep(options))'
check packages/shell/ios/MainMenu.swift 'BroName.install()'
check packages/shell/ios/AppUpdater.swift 'is a personal fork of Ardia'

T=$B/src/components/toolbar/Toolbar.tsx
check $T '(fork) Zen-style toolbar'
check $T 'const navStep = row.button + 4;'
check $T 'const statusRight = '
check $T '(fork) centre the domain on the toolbar'
check $T '(fork) no container behind the address'
check $T '(fork) no address field'
check $T 'const DOMAIN_REST = 0.5;'
check $T 'openWindowPanel(windowId, tab.url, undefined, "centred");'
check $T '<QuietLightDots'
check apps/browser/src/components/sidebar/Sidebar.tsx '<QuietLightDots'
check apps/browser/src/components/window/QuietLightDots.tsx 'trafficLightsFrames(windowId)'
check apps/browser/src/lib/brand.ts 'export function setBrandName'
check apps/browser/src/components/sidebar/SidebarField.tsx 'CLAUDE_ORANGE_HOVER : CLAUDE_ORANGE'

check $B/src/state/omnibox/barPlacement.ts 'return "centred"; // (fork)'
check $B/src/state/commands/commands.ts '(fork) Cmd+L again closes the command bar'
check $B/src/components/omnibox/CommandPanel.tsx 'FLOATING_SHADOW'

D=$B/src/components/window/SidebarDock.tsx
check $D 'layout.pinnedTop - layout.sidebarHeader - layout.sidebarInset'
check $D 'SIDEBAR_GROUND'
check $B/src/components/window/useDockLights.ts 'setTrafficLightsHidden(windowId, concealed)'
check $B/src/components/window/useDockLights.ts '(fork) a hidden left sidebar leaves the traffic lights where they are'
check $B/src/components/profiles/ProfileDots.tsx '<ProfileIndicator room='
check $B/src/components/profiles/ProfileDots.tsx 'FOOTER_EDGE'
check $B/src/components/sidebar/Sidebar.tsx 'const footerDownloads = hasDownloads;'
check $B/src/components/toolbar/Toolbar.tsx '<LoadingPill key={tab.id}'
check $B/src/components/window/CliControlPill.tsx 'Object.values(s.tabs).includes(tabId)'
check apps/cli/ardia_cli/browse/state.py 'async def announce_target'
check apps/cli/ardia_cli/browse/tabs.py 'async def wake_app_tab'
check apps/cli/ardia_cli/browse/capture.py '@command("frames")'
check apps/cli/ardia_cli/browse/commands.py 'async def go_offscreen'
check apps/browser/src/lib/sidebarMetrics.ts 'inset: 3, gap: 3'
check apps/browser/src/components/sidebar/tokens.ts '=> true;'
check apps/browser/src/lib/sidebarMetrics.ts 'SIDEBAR_GROUP_ROW = { height: 28 }'
check apps/browser/src/components/sidebar/GroupBlock.tsx 'chevron sits at the right edge'
check apps/browser/src/components/sidebar/GroupBlock.tsx 'no close button on the header'
check apps/browser/src/components/sidebar/PageRows.tsx 'lift={0}'
check apps/browser/src/components/site/ZoomControls.tsx 'no zoom button in the toolbar at rest'
check apps/browser/src/components/toolbar/Toolbar.tsx 'domain sits in a soft rounded pill'
check packages/shell/ios/AppUpdater.swift 'github.com/stackoverprof/bro-wser'
check apps/browser/src/components/toolbar/Toolbar.tsx 'showToolbarMenu(tab, { inSplit, tabsShown })'
check apps/browser/src/components/window/useDockLights.ts 'In Minimalism mode it'
check apps/browser/macos/Ardia-macOS/Info.plist '$(BRO_APP_NAME)'
check apps/browser/src/components/toolbar/Toolbar.tsx 'HAIRLINE_OPACITY = 0.12'
check apps/browser/src/components/toolbar/NavButtons.tsx 'CIRCLE_LIFT'

check packages/shell/ios/WindowManager.swift 'final class QuietLights'
check packages/shell/ios/AppWindowsModule.swift 'AsyncFunction("setTrafficLightsQuiet")'
check packages/shell/ios/AppWindowsModule.swift 'AsyncFunction("trafficLightsFrames")'
check packages/shell/ios/AppWindowsModule.swift 'AsyncFunction("setTrafficLightsHidden")'
check packages/shaders/ios/WindowTreatmentView.swift '(fork) a far more see-through window frame'

if git grep -n 'preferredImageVisibility = ' -- packages/shell/ios >/dev/null 2>&1 && ! xcodebuild -version 2>/dev/null | grep -q 'Xcode 2[7-9]'; then
  echo "NOTE: upstream code uses preferredImageVisibility again; Xcode 26 can't compile it (see FORK.md, Builds with Xcode 26)"; missing=1
fi

[ "$missing" = 0 ] && echo "All Bro tweaks are in place."
exit $missing
