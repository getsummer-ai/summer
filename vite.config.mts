import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import vue from '@vitejs/plugin-vue';
// import * as svelte from "svelte";
import { svelte, vitePreprocess } from "@sveltejs/vite-plugin-svelte";
// import { resolve } from 'path';

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
    // rollupOptions: {
    //   output: {
    //     manualChunks: {}
    //   }
    // }
  }
  // css: {
  //   preprocessorOptions: {
  //     scss: {
  //       sourceMap: false,
  //       additionalData(source: any, fp: any) {
  //         if (fp.endsWith('variables.scss')) return source;
  //
  //         return `@import "@/assets/css/_variables.scss"; ${source}`;
  //       },
  //     },
  //   },
  // },
});
