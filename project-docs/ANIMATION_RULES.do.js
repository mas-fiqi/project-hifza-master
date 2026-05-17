export const ANIMATION_RULES = {
  timing: {
    snappy: "200ms",
    default: "300ms",
    slow: "500ms (for transitions)"
  },
  easing: "Curves.easeInOutQuart",
  effects: {
    button_press: "Scale down (0.95) then bounce back.",
    card_entrance: "Slide up + Fade in.",
    success_celebration: "Confetti + Floating mascots.",
    floating_idle: "Sinusoidal vertical movement for mascots."
  },
  page_transitions: "Storybook-style flip or smooth cross-fade."
};
