const path = require('path');
module.exports = {
  extends: ['plugin:svelte/recommended'],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: path.resolve(__dirname, '../../../tsconfig.json'),
    extraFileExtensions: ['.svelte'], // This is a required setting in `@typescript-eslint/parser` v4.24.0.
  },
  overrides: [
    {
      files: ['*.svelte'],
      parser: 'svelte-eslint-parser',
      parserOptions: {
        parser: '@typescript-eslint/parser'
      }
    }
  ]
};
