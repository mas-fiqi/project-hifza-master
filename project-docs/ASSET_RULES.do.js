export const ASSET_RULES = {
  images: {
    format: "PNG or WebP",
    naming: "snake_case (e.g., doa_tidur.png)",
    directory: "assets/images/",
    optimization: "Max 300px width for thumbnails, high-res only for full backgrounds."
  },
  audio: {
    format: "MP3 for long audio, WAV for short effects.",
    directory: "assets/audio/",
    logic: "Preload audio effects to avoid lag during playback."
  },
  fonts: {
    primary: "assets/fonts/Nunito/",
    arabic: "assets/fonts/Amiri/"
  }
};
