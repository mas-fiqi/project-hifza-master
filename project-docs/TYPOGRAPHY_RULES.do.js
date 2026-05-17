export const TYPOGRAPHY_RULES = {
  primary_font: "Nunito (for readability and child-friendliness)",
  arabic_font: "Amiri or AmiriQuran (for clarity and traditional beauty)",
  hierarchy: {
    h1: { size: 28, weight: "bold", spacing: 0.5 },
    h2: { size: 22, weight: "bold", spacing: 0.5 },
    body: { size: 16, weight: "normal", spacing: 0.2 },
    caption: { size: 12, weight: "normal", spacing: 0.1 },
    arabic_large: { size: 36, family: "Amiri", spacing: 1.5 }
  },
  rules: [
    "No uppercase only strings (less readable for kids).",
    "Line height minimum 1.5 for body text.",
    "Contrasting but soft text colors (avoid pure #000000, use dark grey or deep teal)."
  ]
};
