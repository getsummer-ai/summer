import '@hotwired/turbo-rails';
import { initApps } from '@/vue/apps/init-vue';
import '@/stimulus/init-stimulus';
import { initSvelteApps } from "@/svelte/apps/init-svelte";
import { StreamActions } from "@hotwired/turbo"
import "chartkick/chart.js"

window.addEventListener('DOMContentLoaded', function () {
  Array.from(document.getElementsByClassName('trigger-submit-form')).forEach((item) => {
    item.addEventListener('click', () => (item as HTMLFormElement).submit());
  });
});

window.addEventListener('turbo:load', () => {
  initApps();
  initSvelteApps();
});

window.Chartkick.config.autoDestroy = false
window.addEventListener('turbo:before-render', () => {
  window.Chartkick.eachChart(chart => {
    if (!chart.element.isConnected) {
      chart.destroy()
      delete window.Chartkick.charts[chart.element.id]
    }
  })
})

window.addEventListener('turbo:frame-render', () => {
  initSvelteApps(false);
})

StreamActions.redirect = function () {
  return window.location.href = this.getAttribute("to");
}

// The action below is used within TurboModalController
StreamActions['close-modal'] = () => {}

// This action is used to reload svelte apps
StreamActions['reload-apps'] = () => { initSvelteApps(false) }
