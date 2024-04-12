import '@hotwired/turbo-rails';
import { initApps } from '@/vue/apps/init-vue';
import '@/stimulus/init-stimulus';
import { initSvelteApps } from "@/svelte/apps/init-svelte";
import { StreamActions } from "@hotwired/turbo"
import { log } from '@/utils/common';

window.addEventListener('DOMContentLoaded', function () {
  Array.from(document.getElementsByClassName('trigger-submit-form')).forEach((item) => {
    item.addEventListener('click', () => (item as HTMLFormElement).submit());
  });
});

// Set up default turbo event listeners

window.addEventListener('turbo:load', () => {
  initApps();
  initSvelteApps();
});

StreamActions.redirect = function () {
  const to = this.getAttribute("to")
  log(to)
  return window.location.href = to;
}
