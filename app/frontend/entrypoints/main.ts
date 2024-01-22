import '@hotwired/turbo-rails';

import { initSvelteApps } from '@/svelte/apps/init-svelte';
import '@/stimulus/init-stimulus';
console.log('Vite ⚡️ Rails ⚡️ MAIN ⚡️ SVELTE');

// window.addEventListener('DOMContentLoaded', animateSlider);
window.addEventListener('turbo:load', () => {
  initSvelteApps();
  console.log('turbo-load');
});
