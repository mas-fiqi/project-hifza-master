export const SRS = {
  technical_architecture: {
    frontend: "Flutter",
    state: "Provider",
    storage: {
      engine: "Hive",
      boxes: [
        "search_history",
        "user_progress",
        "app_settings",
        "hafalan_history",
        "reading_session"
      ]
    },
    api_endpoints: {
      base_url: "http://10.176.175.95:8000/api",
      voice_evaluate: "/voice/evaluate"
    }
  },
  feature_logic: {
    unlock_system: {
      free_tier: ["Al-Fatihah", "Juz 30 (Surah 78-114)"],
      sequential_unlock: "Surah n unlocks if Surah n-1 has score >= 85%",
      juz_unlock: "Juz n unlocks if Juz n-1 has score >= 85%"
    },
    scoring: {
      stars: {
        "3_stars": "score >= 85",
        "2_stars": "score >= 70",
        "1_star": "score >= 50"
      },
      badges: ["Istiqomah 7 Hari", "Santri Rajin (50 sessions)", "Hafalan Mumtaz (Score 90)", "Khatam Surah (114 surah)"]
    }
  }
};
