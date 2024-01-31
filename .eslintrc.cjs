const path = require("path");

module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    // 'plugin:import/recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint'],
  settings: {
    'import/resolver': {
      'eslint-import-resolver-custom-alias': {
        alias: {
          '@': path.resolve(__dirname, 'app/frontend'),
        },
        extensions: ['.js', '.ts', '.vue', '.svelte', '.d.ts'],
      },
      node: {
        extensions: [".js", ".ts"]
      }
    },
  },
};
