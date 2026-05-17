export const DEVELOPMENT_HISTORY = {
  milestones: [
    {
      date: "2026-05-12",
      event: "Initial UI Redesign started.",
      result: "Home screen and Prayer screens moved to pastel/organic style."
    },
    {
      date: "2026-05-15",
      event: "Voice Evaluation Service integrated.",
      result: "Recorder widget successfully uploads audio to FastAPI backend."
    },
    {
      date: "2026-05-17",
      event: "Uji Juz UX & Gamification Refactoring.",
      result: "Reverted to live offline STT for speed. Added word-level error highlights, missing word detection, and smooth test-completion animations."
    }
  ],
  logs: [
    "Added HiveManager for state persistence.",
    "Created QuranDataService for local JSON parsing.",
    "Implemented gamification logic (score-based unlocking).",
    "Enhanced visual feedback for recitation errors."
  ]
};
