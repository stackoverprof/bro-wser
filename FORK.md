# Bro: what this fork changes

Bro is Erbin's fork of Ardia (`ardia-browser/ardia`), on branch `erbin`. This file is the list of everything the
fork changes on purpose. When Ardia is merged in, every item here must still be true afterwards. Fork-only code is
marked with a `(fork)` comment, and `scripts/bro/check-tweaks.sh` checks the markers are still in place.

Update with `scripts/bro/update.sh`. If a merge conflicts with one of these, keep the tweak and adapt it to the new
upstream code. Never drop one to make a merge go through; ask Erbin instead.

## Identity and build

- **Named Bro**, with its own icon: dark dots forming a sphere on a white tile (`AppIcon.icon`, `Info.plist`).
  The Xcode product, the executable and the `ardia` command keep the name Ardia.
- **Everything shown says Bro.** Upstream's text says "Ardia" in hundreds of places; it is swapped where text is
  shown, not edited line by line: `lib/brand.ts` (used by `ui/Text`, button tooltips, field placeholders, dialogs)
  and `BroName` in `MainMenu.swift` (every menu, as it opens). "Little Ardia" reads "Little Bro". Credit and licence
  lines are never rewritten, and About opens with "Bro is a personal fork of Ardia".
- **Own app id and signing:** `is.erbin.ardia`, team `B39983B5VG` (`project.pbxproj`). Data lives in
  `~/Library/Application Support/is.erbin.ardia`.
- **Public releases:** `scripts/bro/package.sh` builds Bro-wser, signs it ad hoc (never with Erbin's certificate,
  which carries his Apple ID) and makes `dist/Bro-wser-<version>-arm64.dmg`; `--release` tags `bro-<version>` and
  publishes it on GitHub. About's Source code, License and Credits links point at that tag in this repo (GPL).
- **README is Bro-wser's**, not upstream's: on a merge that touches `README.md`, keep ours.
- **No auto-update:** `SUFeedURL` is empty and `SUEnableAutomaticChecks` is false, because the official feed would
  replace Bro with stock Ardia. Updates come from merging upstream here.
- **Builds with Xcode 26:** upstream builds with Xcode 27. Patched: `preferredImageVisibility` removed in
  `MenusModule.swift` and `SharePicker.swift`; one expression spelled out in `ThemeGradient.swift` and one each in `ChromiumFavicons.swift` and `FieldGlowGeometry.swift`. Drop these once
  this Mac has Xcode 27.

## Toolbar

- Back, forward and reload sit on the **right**, before the extensions, 4 pt between their hover plates.
- **No address field.** Only the domain shows, centred on the toolbar's full width, with no container behind it.
  At rest it is a shade of the toolbar's tint (50%); on hover it is full ink. Clicking it opens the command bar.
- **Loading pill.** While a page loads, a small 40 x 4 pill (a brighter bar that stretches in from the left and leaves on the right, on a loop) takes the domain's place (they cross-fade), as in Zen. No hairline along the toolbar's bottom edge.
  The hover-only field buttons (bookmark, copy link, split, site controls) are gone; status icons stay.
- **Traffic lights at the toolbar's left** when the sidebar is hidden. At rest they are quiet dots in the page's
  ink, drawn by the toolbar on the real buttons' frames; hovering the corner shows the real coloured lights.

## Command bar

- Cmd+L always opens it **in the middle of the window**, on a wide soft shadow. No blur or dimming behind it.
- **Cmd+L again closes it.**

## Sidebar

- When it slides in over the page it shows **no traffic lights** and no header row; the pinned tiles start as far
  from the top as from the sides. **Nothing sits above the pinned tiles.**
- The **downloads button is in the footer**, at the far left, before the profile name.
- The sidebar keeps a **darker ground** than the window frame, docked or sliding.
- The **profile name is in the footer**, at the left, with the profile dots at the right; evenly padded.

- **Each tab group in its own box.** Every group's box shows at rest (upstream shows it only on hover or for a coloured group), with a little space between boxes and tabs not indented inside. Rows inside a box (header and tabs) are 28pt instead of 34pt, so a group reads compact (`SIDEBAR_GROUP_ROW`, the `RowHeight` context in `sidebar/rowHeight.ts`, and the `inGroup` flag in `state/sidebar/geometry.ts`). The group's chevron sits at the right edge, and the header has no close button: Close Group is only in the right-click menu. The header shows only the group's own icon, never its first tab's favicon, so it no longer looks like a tab (`SIDEBAR_GROUP` in `lib/sidebarMetrics.ts`, `groupBoxAtRest` in `sidebar/tokens.ts`, `GroupBlock.tsx`).
- **Domain pill on hover.** Hovering the toolbar's domain text puts it in a soft rounded pill (`DOMAIN_PILL` in `toolbar/Toolbar.tsx`).
- **Minimal Tab replaces Ardia's Minimalism mode.** Per tab, not browser-wide: while a window shows a tab marked minimal (`Tab.minimal`), that window hides the toolbar and the page frame, and nothing else changes (no address field in the sidebar, other windows and tabs untouched). `minimalismIn` in `state/windows/layout.ts` reads the active tab instead of the setting; ⌃⌘M (`toggleMinimalism` in `state/commands/commands.ts`), the toolbar's right-click menu and the sidebar tab menu (`minimalTab` in `state/sidebar/tabMenu.ts`) toggle it. The Minimalism setting is gone from Settings. The sidebar and tab strip never change for it (the `useMinimalism` reads in `sidebar/rowLook.ts`, `tabstrip/PinnedFace.tsx`, `tabstrip/TopTabStrip.tsx` and `peek/usePeekPageTop.ts` are off), and the traffic lights hide while it is shown (`minimal` in `window/useDockLights.ts`).
- **The toolbar holds only back, forward and reload** (and the domain). The sidebar button, the field's buttons (reader, translate, pop-ups, site controls), the split pane buttons and the zoom button are gone; a right click anywhere on the toolbar opens a menu with all of them plus copy/paste/share, bookmark, zoom, split view, show tabs, Minimal Tab and Inspect (`toolbar/toolbarMenu.ts`). Extensions stay.
- **No zoom button in the toolbar.** A zoomed page shows no magnifier in the toolbar; the zoom bubble still appears while ⌘+ / ⌘- changes it (`ZoomIndicator` in `site/ZoomControls.tsx`).
- **Clear sits clear of the pinned tiles.** The divider with Clear is no longer pulled up under docked tiles (`lift={0}` in `sidebar/PageRows.tsx`).

## Window frame

- A thinner, **lighter** wash over the blurred desktop (white wash in dark mode), so the frame reads as see-through.

## Bro-claude

- **Two apps from one source.** `build.sh` / `install.sh` make Bro (`is.erbin.ardia`, for Erbin); `build.sh claude` / `install.sh claude` make **Bro-claude** (`is.erbin.ardia.claude`, where Claude's agents browse), with its own data dir, name (`BRO_APP_NAME`) and an inverted icon (`AppIconClaude.icon`: white dots on a dark tile).
- **Bro-claude's frame colour** is its profile's colour or theme, set in the app like any profile's. Its sidebar address bar is always Claude orange (#D97757, `state/app/claudeApp.ts`).
- **Stronger toolbar hairline** in both: 1 pt in the page's ink at 12%, instead of a hairline-width divider that vanishes on low-DPI screens.
- **Docked sidebar has the frame's colour;** only the sliding-in sidebar gets a darker ground.
- **Reload icon centred on its circle** (lifted 1 pt past the arrowhead) and toolbar buttons on whole points, so nothing sits low on low-DPI screens.

- **Quiet traffic lights wherever they are:** grey dots at rest, the real lights on hover, in the toolbar or in a docked sidebar (`QuietLightDots.tsx`).
- **Each app says its own name** (menus, window title, About, interface text): the bundle's `CFBundleName`, so Bro-claude never says Bro or Ardia.

## The ardia command

- **Control pill on the driven tab only.** "Claude Code is controlling Bro" shows only on the tab an `ardia browse` session drives, not on every tab in every profile. The CLI tells Bro which page it drives after each command (`using`, in `browse/state.py` and `control.py`); Bro maps it to a tab (`controlSocket.ts`) and the pill checks it (`CliControlPill.tsx`).
- **Sleeping tabs wake on their own.** Driving a tab Bro keeps asleep (`ardia browse tab <tab-id>` on a tab not shown since launch, or put to sleep) wakes it in the background and waits for its page, instead of failing with `tab_asleep` and needing a click (`wake_app_tab` in `browse/tabs.py`).
- **GIF frames from a background tab.** `browse frames start <dir> [--fps 15]` / `frames stop` screenshots the session's tab into `<dir>/frames/*.jpg` plus `frames.json` (the format `~/.claude/skills/walkthrough/gif/compose.py` reads), so walkthrough GIFs record in Bro-claude now that Zen is gone (`cmd_frames` in `browse/capture.py`). About 6 frames a second, in device pixels; upstream's `record` needs screencast, which Ardia's policy blocks.
- **Phone-size pages work.** `set viewport <w> <h>` (and `set device`) first moves the session's background tab into Bro's off-screen automation window, where the engine allows it, instead of failing with "not on a tab that isn't off-screen". It's upstream's own CLI half of 5e8568ee1 (`go_offscreen` in `browse/commands.py`), which the installed CLI 0.2.46 predates; the app half was already in Bro. `set viewport reset` or `--show` reopens the page in a normal tab.
- The ardia command itself is upstream's release download, so `scripts/bro/cli-patch.sh` copies the fork's CLI files over it. `install.sh` runs it; re-run it after the CLI updates.
