export const COMPONENT_REGISTRY = {
  screens: {
    splash: "lib/screens/splash/splash_screen.dart",
    home: "lib/screens/home/home_screen.dart",
    quran_list: "lib/screens/quran/quran_list_screen.dart",
    uji_suara: "lib/screens/uji/uji_suara_screen.dart",
    skor_hafalan: "lib/screens/skor/skor_hafalan_screen.dart",
    settings: "lib/screens/settings/settings_screen.dart"
  },
  widgets: {
    custom_app_bar: "lib/widgets/app_bar_custom.dart",
    surah_card: "lib/widgets/card_surah.dart",
    audio_controls: "lib/widgets/audio_control_widget.dart",
    recorder: "lib/screens/recorder/recorder_widget.dart"
  },
  services: {
    hive: "lib/data/local_db/hive_manager.dart",
    quran: "lib/services/quran_data_service.dart",
    gamification: "lib/services/gamification_service.dart",
    voice: "lib/services/speech_service.dart"
  }
};
