import '@hotwired/turbo-rails';
import '@/stimulus/init-stimulus';
import { initSvelteApps } from '@/svelte/apps/init-svelte';
console.log('Vite ⚡️ Rails ⚡️ MAIN ⚡️ SVELTE');
// window.addEventListener('DOMContentLoaded', animateSlider);
window.addEventListener('turbo:load', () => {
  initSvelteApps();
  console.log('turbo-load');
});
