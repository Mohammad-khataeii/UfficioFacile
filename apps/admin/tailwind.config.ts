import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#eef5ff",
          100: "#d8e7ff",
          200: "#b9d2ff",
          300: "#88b2ff",
          400: "#4d84ff",
          500: "#2557f5",
          600: "#183fd2",
          700: "#1734aa",
          800: "#192e86",
          900: "#1a2b6d",
        },
      },
      boxShadow: {
        soft: "0 12px 30px rgba(15, 23, 42, 0.08)",
      },
    },
  },
  plugins: [],
};

export default config;
