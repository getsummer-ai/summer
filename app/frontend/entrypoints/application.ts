import '@hotwired/turbo-rails';

import { initApps } from '@/vue/apps/init-vue';
import '@/stimulus/init-stimulus';
// initApps();
console.log('Vite ⚡️ Rails ⚡️ Private');
window.addEventListener('DOMContentLoaded', function () {
  Array.from(document.getElementsByClassName('trigger-submit-form')).forEach((item) => {
    item.addEventListener('click', () => (item as HTMLFormElement).submit());
  });
});

window.addEventListener('turbo:load', () => {
  initApps();
  console.log('turbo-load');
});
