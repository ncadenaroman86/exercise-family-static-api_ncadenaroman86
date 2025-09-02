import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 5173,          // or 3000 if you prefer
    strictPort: true,
    hmr: { clientPort: 443 }
  }
});
