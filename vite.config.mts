import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import vue from '@vitejs/plugin-vue';
import { svelte, vitePreprocess } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue'],
  },
  plugins: [
    svelte({
      emitCss: false,
      preprocess: [vitePreprocess()]
    }),
    vue(),
    RubyPlugin()
  ],
  build: {
    minify: false,
    sourcemap: true,
    commonjsOptions: {
      strictRequires: true
    }
  }
});
