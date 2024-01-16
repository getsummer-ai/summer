import '@hotwired/turbo-rails';

import { initApps } from '@/init-vue';
import '@/init-stimulus';
initApps();
console.log('Vite ⚡️ Rails ⚡️ MAIN');

// window.addEventListener('DOMContentLoaded', animateSlider);
window.addEventListener('turbo:load', () => {
  console.log('turbo-load');
});
