import { defineConfig } from 'vite';
import { svelte, vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import { resolve } from 'path';
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [
    tsconfigPaths(),
    svelte({
      emitCss: false,
      preprocess: [vitePreprocess()],
      compilerOptions: {
        cssHash: ({ hash, css }) => `gs-${hash(css)}`
      }
    }),
  ],
  resolve: {
    alias: {
      "@": resolve(__dirname, 'app/frontend')
    }
  },
  build: {
    emptyOutDir: false,
    copyPublicDir: false,
    minify: true,
    manifest: true,
    // cssMinify: 'lightningcss',
    lib: {
      formats: ['umd'],
      entry: resolve(__dirname, 'app/frontend/libs/summer.ts'),
      name: 'Summer',
      fileName: 'app',
    },
    outDir: resolve(__dirname, "public/libs"),
    rollupOptions: {
      output: {
        entryFileNames: 'app.[hash].js',
        inlineDynamicImports: true
      }
    },
  },
  esbuild: { legalComments: 'none' },
});
