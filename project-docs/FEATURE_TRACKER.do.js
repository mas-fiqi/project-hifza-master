export const FEATURE_TRACKER = {
  core_features: {
    quran_reader: {
      status: "completed",
      ui: "Premium Storybook",
      data: "Local JSON assets",
      features: ["Surah list", "Ayah navigation", "Last read tracking"]
    },
    voice_test: {
      status: "completed",
      ui: "Mascot-led interaction",
      integration: "FastAPI Backend",
      accuracy_logic: "Phonetic matching (score 0-100)"
    },
    gamification: {
      status: "completed",
      logic: "Sequential Unlock (score >= 85)",
      rewards: ["Stars (1-3)", "Badges", "Levels (Pemula to Khatam)"],
      storage: "Hive"
    },
    daily_doa: {
      status: "completed",
      ui: "Interactive cards",
      asset_loader: "Dynamic snake_case mapping"
    }
  },
  development_history: [
    "Initial Setup with Flutter & Hive",
    "Quran data integration (JSON)",
    "Voice evaluation API connection",
    "UI Redesign to Premium Storybook theme",
    "Gamification logic & persistent progress"
  ]
};
