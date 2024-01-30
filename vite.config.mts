import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import vue from '@vitejs/plugin-vue';
// const path = require('path');
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
    rollupOptions: {
      output: {
        entryFileNames: function (file) {
          // console.log(file.name, file.type)
          // let name = file.name.split('.')[0]
          // if (!file.name.startsWith('pixels')) {
          //   name = name.split('/')[1]
          // }
          const name = file.name.split('.')[0]
          if (file.name.startsWith('pixels')) {
            if (file.name === 'pixels/init.ts') return `pixels/init.js`
            return `${name}-[hash].js`;
          }
          return `assets/${name}-[hash].js`;
        },
      }
    },
    commonjsOptions: {
      strictRequires: true
    }
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
