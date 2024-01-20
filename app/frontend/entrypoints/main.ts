import '@hotwired/turbo-rails';

import { initApps } from '@/vue/apps/init-vue';
import '@/stimulus/init-stimulus';
initApps();
console.log('Vite ⚡️ Rails ⚡️ MAIN');

// window.addEventListener('DOMContentLoaded', animateSlider);
window.addEventListener('turbo:load', () => {
  console.log('turbo-load');
});
