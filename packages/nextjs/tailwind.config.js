// tailwind.config.js
const { heroui } = require("@heroui/theme");

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./node_modules/@heroui/theme/dist/components/(button|form|input|ripple|spinner).js"],
  theme: {
    extend: {
      zIndex: {
        '12': '12',
      },
    },
  },
  darkMode: "class",
  plugins: [heroui()],
};
