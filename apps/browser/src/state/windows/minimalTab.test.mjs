// (fork) Minimal Tab: the window's layout follows its shown tab's flag, and window-keyed hooks hear the flip at once.
import assert from "node:assert/strict";
import { test } from "node:test";
const { minimalismIn, pageFrameIn } = await import("./layout.ts");
const { useBrowser } = await import("../browser/store.ts");
const { watchWindowSettings } = await import("../browser/keyedWatch.ts");

const tab = (id, extra = {}) => ({ id, windowId: "w", profileId: "p", url: "https://example.com", page: { kind: "idle" }, ...extra });
function seed(minimal) {
  const s = useBrowser.getState();
  useBrowser.setState({
    windows: { w: { id: "w", kind: "main", profileId: "p", tabIds: ["a", "b"], activeTabIds: { p: "a" }, frame: null, createdAt: 0 } },
    tabs: { a: tab("a", minimal ? { minimal: true } : {}), b: tab("b") },
    settings: { ...s.settings, pageFrame: 8, borderlessMode: false },
  });
}

test("only the window showing a minimal tab is minimal, and its page frame is gone", () => {
  seed(true);
  const s = useBrowser.getState();
  assert.equal(minimalismIn(s, "w"), true);
  assert.equal(pageFrameIn(s, "w"), 0);
  useBrowser.setState({ windows: { w: { ...s.windows.w, activeTabIds: { p: "b" } } } });
  assert.equal(minimalismIn(useBrowser.getState(), "w"), false);
  assert.ok(pageFrameIn(useBrowser.getState(), "w") > 0);
});

test("flipping a tab's flag wakes its window's watchers right away", () => {
  seed(false);
  let woken = 0;
  const stop = watchWindowSettings("w", () => woken++);
  const s = useBrowser.getState();
  useBrowser.setState({ tabs: { ...s.tabs, a: { ...s.tabs.a, minimal: true } } });
  assert.equal(woken, 1);
  assert.equal(minimalismIn(useBrowser.getState(), "w"), true);
  const t = useBrowser.getState().tabs;
  useBrowser.setState({ tabs: { ...t, a: { ...t.a, minimal: undefined } } });
  assert.equal(woken, 2);
  useBrowser.setState({ tabs: { ...useBrowser.getState().tabs, b: { ...t.b, title: "x" } } });
  assert.equal(woken, 2, "other tab changes don't wake it");
  stop();
});
