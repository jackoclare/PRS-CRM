import type { Config } from "tailwindcss";
export default { content: ["./src/**/*.{ts,tsx}"],
 theme: { extend: { colors: { ink: "#15232B", paper: "#F4F5F3", steel: "#2F5D8A", hot: "#E0861A", line: "#DADFDC" } } } } satisfies Config;
