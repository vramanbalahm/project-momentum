import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react' // Using the standard plugin
import tailwindcss from '@tailwindcss/vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
  server: {
    host: '0.0.0.0',   // allow network access
    port: 5173,
  },
})