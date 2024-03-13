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
    fontSize: {
      xs: ['12px', '15px'],
      sm: ['13px', '16px'],
      base: ['15px', '22px'],
      lg: ['20px', '26px'],
      xl: ['24px', '32px'],
      '2xl': ['32px', '40px'],
      '3xl': ['48px', '54px'],
      '6xl': ['74px', '82px'],
    },
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
      green: colors.green,
      black: colors.black,
      white: colors.white,
      gray: colors.gray,
      emerald: colors.emerald,
      // red: colors.red,
      red: {
        50: '#fef3f2',
        100: '#fee4e2',
        200: '#fecdca',
        300: '#fcaaa5',
        400: '#f77972',
        500: '#ed4339',
        600: '#db3127',
        700: '#b8261d',
        800: '#98231c',
        900: '#7e231e',
        950: '#450d0a',
      },
      indigo: colors.indigo,
      orange: colors.orange,
      yellow: '#FFCF24',
      blue: '#2FA8FF',
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
