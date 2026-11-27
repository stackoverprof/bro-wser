// (fork) Bro's toolbar keeps only back, forward and reload. Everything else Ardia puts in the toolbar (the sidebar
// button, the address field's buttons, the status icons and the split pane buttons) lives in this menu, opened by a
// right click anywhere on the toolbar.
import { markdownLink } from "@ardia/core";
import { copyText } from "../../platform/clipboard";
import { showMenu, type MenuItem } from "../../platform/menus";
import { menuSections } from "../../state/app/menuSections";
import { useBrowser } from "../../state/browser/store";
import { focusModeAllowed, minimalismIn } from "../../state/windows/layout";
import { menuShortcut } from "../../state/commands/commandShortcuts";
import { runCommand } from "../../state/commands/commands";
import { clipboardPasteAction, pasteTarget, urlBarMenuItems } from "../../state/omnibox/paste";
import { toggleReader, useReader } from "../../state/reader/reader";
import { toggleTranslation, translation, useTranslate } from "../../state/site/translate";
import { canShare, shareTab } from "../../state/site/share";
import { copyPageUrl } from "../../state/site/selection";
import { closePane, openSplitPane, showSplitMenu } from "../../state/splits/actions";
import { navigate } from "../../state/tabs/actions";
import { usePages } from "../../state/tabs/pageState";
import { togglePopover } from "../../state/tabs/popoverDismiss";
import type { Tab } from "../../state/browser/types";

type MenuTab = Pick<Tab, "id" | "url" | "title" | "windowId" | "zoom"> & Partial<Pick<Tab, "customTitle">>;

const COMMANDS = ["zoomIn", "zoomOut", "zoomReset", "bookmarkPage", "toggleSidebar", "toggleMinimalism", "inspectElements"] as const;

export async function showToolbarMenu(tab: MenuTab, o: { inSplit: boolean; tabsShown: boolean }) {
  const s = useBrowser.getState();
  const reader = useReader.getState()[tab.id];
  const translate = useTranslate.getState()[tab.id];
  const translated = !!translate && translate.status !== "idle";
  const translatable = !!translation && (translated || !!translate?.source);
  const popups = usePages.getState().pages[tab.id]?.popups.length ?? 0;
  const paste = await clipboardPasteAction();
  const zoom = Math.round((tab.zoom || 1) * 100);
  const item = (id: string, title: string, symbol?: string, command?: string): MenuItem => ({ id, title, symbol, ...(command ? menuShortcut(command) : {}) });
  const items = menuSections(
    [
      (reader?.available || reader?.active) && item("reader", reader?.active ? "Hide Reader" : "Show Reader", "doc.plaintext", "toggleReader"),
      translatable && item("translate", translated ? "Show Original" : "Translate Page", "translate"),
      popups > 0 && item("popups", `Blocked Pop-ups (${popups})…`, "macwindow.badge.plus"),
      item("siteControls", "Site Controls…", "slider.horizontal.3"),
    ],
    urlBarMenuItems({ paste, shareable: canShare(tab) }),
    [item("bookmarkPage", "Add to Bookmarks…", "bookmark", "bookmarkPage")],
    [
      item("zoomIn", "Zoom In", "plus.magnifyingglass", "zoomIn"),
      item("zoomOut", "Zoom Out", "minus.magnifyingglass", "zoomOut"),
      item("zoomReset", zoom === 100 ? "Actual Size" : `Actual Size (now ${zoom}%)`, "1.magnifyingglass", "zoomReset"),
    ],
    o.inSplit
      ? [item("splitMenu", "Split View…", "rectangle.split.2x1"), item("closePane", "Close Pane", "xmark")]
      : [item("openSplit", "Open Split View", "rectangle.split.2x1", "openSplitPane")],
    [
      item("toggleSidebar", o.tabsShown ? "Hide Tabs" : "Show Tabs", "sidebar.left", "toggleSidebar"),
      { ...item("toggleMinimalism", "Focus Mode", undefined, "toggleMinimalism"), checked: minimalismIn(s, tab.windowId), enabled: focusModeAllowed(s, tab.id) },
      item("inspectElements", "Inspect Elements", "magnifyingglass", "inspectElements"),
    ],
  );
  const choice = await showMenu(items);
  if (!choice) return;
  if (choice === "reader") return void toggleReader(tab.id);
  if (choice === "translate") return toggleTranslation(tab.id);
  if (choice === "popups") return togglePopover(tab.id, "popups");
  if (choice === "siteControls") return togglePopover(tab.id, "siteControls");
  if (choice === "splitMenu") return void showSplitMenu(tab.id);
  if (choice === "closePane") return void closePane(tab.id);
  if (choice === "openSplit") return void openSplitPane(tab.windowId, { anchorTabId: tab.id });
  if ((COMMANDS as readonly string[]).includes(choice)) return void runCommand({ command: choice as (typeof COMMANDS)[number], arg: null, windowId: tab.windowId }, { tabId: tab.id });
  // the address menu's own items, handled as showUrlBarMenu does
  if (choice === "pasteAndGo" && paste) navigate(tab.id, pasteTarget(paste));
  if (choice === "copy") void copyPageUrl(tab.id);
  if (choice === "copyMarkdown") copyText(markdownLink(tab.customTitle || tab.title, tab.url));
  if (choice.startsWith("share:via:")) void shareTab({ url: tab.url, title: tab.title, customTitle: tab.customTitle ?? null }, tab.windowId, choice.slice("share:via:".length));
}
