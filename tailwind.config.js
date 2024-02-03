const colors = require('tailwindcss/colors');

/** @type {import('tailwindcss').Config} */

module.exports = {
  darkMode: 'class',
  content: [
    './app/helpers/**/*.rb',
    './app/builders/**/*.rb',
    './app/components/**/*.erb',
    './app/frontend/**/*.{js,vue,ts,svelte}',
    './config/initializers/simple_form.rb',
    './app/views/**/*',
  ],
  theme: {
    extend: {},
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
      black: colors.black,
      white: colors.white,
      gray: colors.gray,
      emerald: colors.emerald,
      red: colors.red,
      indigo: colors.indigo,
      yellow: colors.yellow,
      'light-gray': '#F6F6F9',
    },
    // container: {
    //   screens: {
    //     sm: '640px',
    //     md: '768px',
    //     lg: '1024px',
    //     xl: '1024px',
    //     '2xl': '1024px',
    //   },
    // },
  },
  plugins: [require('@tailwindcss/typography'), require('daisyui')],
  daisyui: {
    themes: ['cupcake', 'lofi'],
  },
};
