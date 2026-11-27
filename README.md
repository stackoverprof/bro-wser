<p align="center">
  <img src="docs/bro/icon.png" width="128" height="128" alt="Bro-wser's app icon: dark dots forming a sphere on a white tile">
</p>

<h1 align="center">Bro-wser</h1>

<p align="center">
  A quieter <a href="https://github.com/ardia-browser/ardia">Ardia</a>.<br>
  The same Chromium browser with Arc's sidebar, with less chrome around the page.
</p>

<h3 align="center">
  <a href="https://github.com/stackoverprof/bro-wser/releases/latest">Download the latest Bro-wser for Mac</a>
</h3>

<p align="center">
  DMG · macOS 14 Sonoma or later · Apple Silicon · Not notarized (see Install)
</p>

## What it is

Bro-wser is a personal fork of [Ardia](https://ardia.dev), the free, open-source Chromium browser with Arc's sidebar
and Dia's polish. Everything Ardia does, Bro-wser does: tabs, pinned tiles, Peek, Split View, Little Ardia, extensions,
ad blocking. On top of that it changes how the window looks and behaves, mostly by taking things away so the page gets
the room.

Each Bro-wser release is built from an Ardia release: Bro-wser 0.2.47 is Ardia 0.2.47 plus the changes below.

## What's different from Ardia

### Toolbar
- **No address field.** The toolbar shows only the site's domain, centred, in a soft shade of the page's colour.
  Hover it and it sits in a small pill; click it to open the command bar, click again to close it.
- **Only back, forward and reload**, on the right before your extensions. Everything else (Reader, Translate,
  Site Controls, Split View, zoom, bookmark, share, Show Tabs, Focus Mode) is in the toolbar's right-click menu.
- **A loading pill** takes the domain's place while a page loads, instead of a bar along the bottom edge.
- **Quiet traffic lights.** Grey dots at rest, the real coloured buttons when you hover the corner.

### Command bar
- **⌘L always opens it in the middle of the window**, floating on a soft shadow, and ⌘L again closes it.

### Sidebar
- **Every tab group sits in its own box**, with compact rows and the chevron at the right edge. Close a group from
  its right-click menu.
- **Nothing above the pinned tiles.** When the sidebar slides in over the page, the tiles start as close to the top
  as to the sides.
- **Downloads and the profile name live in the footer**, with the profile dots.
- **A darker ground** for the sliding sidebar, so it reads apart from the page.

### Focus Mode (⌃⌘M)
- Instead of Ardia's browser-wide Minimalism, mark just the tabs you want (a slide deck, say) as Minimal, from ⌃⌘M or
  the tab's right-click menu. While one is showing, its window hides the toolbar and the frame; every other tab and
  window stays as it is. It's off in split view: a split tab always keeps its toolbar and frame.

### Window
- A lighter, more see-through frame over the desktop.
- The interface says Bro-wser wherever Ardia's says Ardia.

The full list, with where each change lives in the code, is in [FORK.md](FORK.md).

## Install

1. Download `Bro-wser-<version>-arm64.dmg` from the [latest release](https://github.com/stackoverprof/bro-wser/releases/latest).
2. Open it and drag Bro-wser into Applications.
3. Bro-wser is signed ad hoc and not notarized by Apple, so macOS blocks it the first time. Run this once in Terminal:

   ```sh
   xattr -dr com.apple.quarantine /Applications/Bro-wser.app
   ```

Bro-wser keeps its data apart from Ardia's, so the two can sit side by side. It doesn't update itself: download the
next release to update.

## Build it yourself

You need Apple Silicon, Xcode 26, Node 24 and pnpm.

```sh
git clone -b bro-wser https://github.com/stackoverprof/bro-wser.git
cd bro-wser
pnpm install && pnpm pods
scripts/bro/build.sh      # builds Bro-wser and prints the app's path
scripts/bro/install.sh    # copies it into /Applications and opens it
```

`scripts/bro/package.sh` makes the release DMG, and `scripts/bro/update.sh` merges a new Ardia release in.

## Credits and licence

Bro-wser is Ardia by [Mantra Patel](https://github.com/mantrakp04) and its contributors, with tweaks by
[stackoverprof](https://github.com/stackoverprof). Like Ardia it is free software under the
[GNU General Public License v3](LICENSE), with no warranty. It is built on Chromium and uBlock Origin, each under its
own licence; see [NOTICE](NOTICE). Bro-wser isn't made or supported by the Ardia team: report Bro-wser problems
[here](https://github.com/stackoverprof/bro-wser/issues), not to Ardia.
