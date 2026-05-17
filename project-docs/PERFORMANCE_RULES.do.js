export const PERFORMANCE_RULES = {
  rendering: [
    "No heavy BackdropFilter (blur) on low-end devices.",
    "Use RepaintBoundary for complex animations.",
    "Lazy load long lists (ListView.builder).",
    "Cache images locally after first load."
  ],
  network: [
    "Timeout evaluation API after 10 seconds.",
    "Show progress indicator during audio upload."
  ],
  general: [
    "Target 60 FPS for all animations.",
    "Minimize build method complexity."
  ]
};
