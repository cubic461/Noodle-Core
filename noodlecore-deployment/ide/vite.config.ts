import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

// @ts-expect-error process is a nodejs global
const host = process.env.TAURI_DEV_HOST;

// Environment variables for build-time configuration
const env = {
  NOODLE_WORKSPACE_DIR: process.env.NOODLE_WORKSPACE_DIR || '../../',
  NOODLE_DEV_DIR: process.env.NOODLE_DEV_DIR || '../../noodle-dev',
  NOODLE_SANDBOX_SCRIPT: process.env.NOODLE_SANDBOX_SCRIPT || '../../noodle-dev/src/noodle/runtime/sandbox.py',
};

// https://vite.dev/config/
export default defineConfig(async () => ({
  plugins: [react()],

  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@services': path.resolve(__dirname, './src/services'),
      '@config': path.resolve(__dirname, './src/config'),
      '@lib': path.resolve(__dirname, './src/lib'),
    },
    extensions: ['.ts', '.tsx', '.js', '.jsx', '.json']
  },

  build: {
    rollupOptions: {
      external: [
        "vscode",
        "vscode-languageserver-protocol/lib/main",
        "vscode-languageserver-protocol/lib/utils/is"
      ]
    }
  },

  // Define environment variables for the frontend
  define: {
    'process.env.NOODLE_WORKSPACE_DIR': JSON.stringify(env.NOODLE_WORKSPACE_DIR),
    'process.env.NOODLE_DEV_DIR': JSON.stringify(env.NOODLE_DEV_DIR),
    'process.env.NOODLE_SANDBOX_SCRIPT': JSON.stringify(env.NOODLE_SANDBOX_SCRIPT),
  },

  // Vite options tailored for Tauri development and only applied in `tauri dev` or `tauri build`
  //
  // 1. prevent Vite from obscuring rust errors
  clearScreen: false,
  // 2. tauri expects a fixed port, fail if that port is not available
  server: {
    port: 1420,
    strictPort: true,
    host: host || false,
    hmr: host
      ? {
          protocol: "ws",
          host,
          port: 1421,
        }
      : undefined,
    watch: {
      // 3. tell Vite to ignore watching `src-tauri`
      ignored: ["**/src-tauri/**"],
    },
  },
}));
