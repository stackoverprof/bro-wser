import { useEffect, useRef } from "react";
import type { Animated } from "react-native";
import { setTrafficLightsCenter } from "../../state/windows/nativeWindow";
import { setTrafficLightsHidden } from "../../platform/windows";
import { dockMoving, sidebarLightsCenter, stillOffWindow, TOP_STRIP_LIGHTS_CENTER } from "../../state/windows/dockMotion";
import { currentValue } from "../ui/motion";

export function useTopStripLights(windowId: string, dock: Animated.Value, on: boolean, travel: number, open: boolean) {
  useEffect(() => {
    if (!on) return;
    const place = (value: number) => {
      if (!dockMoving(windowId)) return;
      const up = Math.round(travel * (1 - value) * 2) / 2;
      void setTrafficLightsCenter(windowId, [TOP_STRIP_LIGHTS_CENTER[0], TOP_STRIP_LIGHTS_CENTER[1] - up]);
    };
    place(currentValue(dock));
    const sub = dock.addListener(({ value }) => place(value));
    return () => dock.removeListener(sub);
  }, [windowId, dock, on, travel, open]);
}

// (fork) `minimal`: Minimalism mode, where there is no toolbar to hold the lights; `open`: the sidebar is docked open
export type SidebarLights = { width: number; peeking: boolean; fullscreen: boolean; lights: readonly [number, number]; right: boolean; peekAt: { left: number; top: number }; minimal?: boolean; open?: boolean };

export function useSidebarLights(windowId: string, dock: Animated.Value, slide: Animated.Value, o: SidebarLights) {
  const values = useRef({ dock: 1, slide: 0 });
  const apply = useRef<() => void>(() => {});
  const sent = useRef<ReturnType<typeof slidingCenter> | undefined>(undefined);
  apply.current = () => {
    const center = slidingCenter(o, values.current.dock, values.current.slide);
    const last = sent.current;
    if ((last && last.join(",") === center.join(",")) || stillOffWindow(last, center)) return;
    sent.current = center;
    void setTrafficLightsCenter(windowId, center);
  };
  useEffect(() => {
    values.current.dock = currentValue(dock);
    const a = dock.addListener(({ value }) => {
      values.current.dock = value;
      apply.current();
    });
    apply.current();
    return () => {
      dock.removeListener(a);
      sent.current = undefined;
      void setTrafficLightsCenter(windowId, null);
    };
  }, [windowId, dock]);
  useEffect(() => {
    if (!o.peeking) return;
    const b = slide.addListener(({ value }) => {
      values.current.slide = value;
      apply.current();
    });
    return () => slide.removeListener(b);
  }, [slide, o.peeking]);
  // (fork) the peeking sidebar shows no traffic lights: they belong to the toolbar it slides over
  // (fork) On a Minimal Tab there is no toolbar to hold them, and the sidebar stays exactly as it is, so they hide
  const concealed = o.minimal ? !o.fullscreen : o.peeking && !o.right && !o.fullscreen;
  useEffect(() => {
    void setTrafficLightsHidden(windowId, concealed);
    return () => void setTrafficLightsHidden(windowId, false);
  }, [windowId, concealed]);
  useEffect(() => apply.current(), [o.width, o.peeking, o.fullscreen, o.lights, o.right, o.peekAt.left, o.peekAt.top, o.minimal]);
}

export function slidingCenter(o: SidebarLights, dock: number, slide: number) {
  // (fork) a hidden left sidebar leaves the traffic lights where they are, at the toolbar's left, instead of sliding them out
  if (!o.minimal && o.peeking && !o.right && !o.fullscreen) return sidebarLightsCenter(false, o.width, 0, 0, o.lights); // (fork) hidden meanwhile, so left in place
  const offset = o.fullscreen ? 0 : o.peeking ? (o.width + 12) * (1 - slide) - o.peekAt.left : o.right ? o.width * (1 - dock) : 0;
  return sidebarLightsCenter(o.right && !o.fullscreen, o.width, offset, o.peeking && !o.fullscreen ? o.peekAt.top : 0, o.lights);
}
