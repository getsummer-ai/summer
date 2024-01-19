/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
    './app/helpers/**/*.rb',
    './app/builders/**/*.rb',
    './app/components/**/*.erb',
    './app/frontend/**/*.{js,vue,ts}',
    './config/initializers/simple_form.rb',
    './app/views/**/*',
  ],
  theme: {
    extend: {},
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
