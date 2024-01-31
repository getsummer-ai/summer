import { defineConfig } from 'vite';
import { svelte, vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import { resolve } from 'path';
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [
    tsconfigPaths(),
    svelte({
      emitCss: false,
      preprocess: [vitePreprocess()]
    }),
  ],
  build: {
    emptyOutDir: false,
    copyPublicDir: false,
    minify: true,
    lib: {
      formats: ['umd'],
      entry: resolve(__dirname, 'app/frontend/libs/init.ts'),
      name: 'InitGetSummerApp',
      fileName: 'init',
    },
    outDir: resolve(__dirname, "public/libs"),
    rollupOptions: {
      output: {
        inlineDynamicImports: true
      }
    },
  }
});
