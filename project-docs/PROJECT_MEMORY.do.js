export const PROJECT_MEMORY = {
  architecture_decisions: [
    {
      date: "2026-05-10",
      decision: "Use Hive for local storage instead of SQLite.",
      rationale: "Faster for simple key-value pairs and easier to integrate with Flutter."
    },
    {
      date: "2026-05-12",
      decision: "Adopt 'Storybook' UI style.",
      rationale: "Better engagement for children vs standard Material/Cupertino."
    }
  ],
  context_memory: {
    voice_backend: "Running on FastAPI at 10.176.175.95:8000.",
    asset_naming_convention: "snake_case is critical for automated loaders."
  }
};
