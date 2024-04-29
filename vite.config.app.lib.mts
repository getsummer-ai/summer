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
  define: {
    'process.env': { NODE_ENV: 'production' }
  },
  build: {
    emptyOutDir: false,
    copyPublicDir: false,
    minify: true,
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
        inlineDynamicImports: true
      }
    },
  },
  esbuild: { legalComments: 'none' },
});
