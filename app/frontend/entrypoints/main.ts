import '@hotwired/turbo-rails';
import '@/stimulus/init-stimulus';
import { initSvelteApps } from '@/svelte/apps/init-svelte';

window.addEventListener('turbo:load', () => {
  initSvelteApps();
});
