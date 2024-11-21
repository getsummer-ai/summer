import '@hotwired/turbo-rails';
import { initApps } from '@/vue/apps/init-vue';
import '@/stimulus/init-stimulus';
import { initSvelteApps } from "@/svelte/apps/init-svelte";
import { StreamActions } from "@hotwired/turbo"
import { log } from '@/utils/common';
import "chartkick/chart.js"

window.addEventListener('DOMContentLoaded', function () {
  Array.from(document.getElementsByClassName('trigger-submit-form')).forEach((item) => {
    item.addEventListener('click', () => (item as HTMLFormElement).submit());
  });
});

// Set up default turbo event listeners

window.addEventListener('turbo:load', () => {
  initApps();
  console.log('turbo:load');
  initSvelteApps();
});

window.Chartkick.config.autoDestroy = false
window.addEventListener('turbo:before-render', () => {
  console.log('turbo:before-render');
  window.Chartkick.eachChart(chart => {
    if (!chart.element.isConnected) {
      chart.destroy()
      delete window.Chartkick.charts[chart.element.id]
    }
  })
})

window.addEventListener('turbo:frame-render', () => {
  console.log('turbo:frame-render');
  initSvelteApps(false);
})


StreamActions.redirect = function () {
  const to = this.getAttribute("to")
  log(to)
  return window.location.href = to;
}
