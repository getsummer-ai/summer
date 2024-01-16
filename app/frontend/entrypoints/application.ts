import { initApps } from '@/init-vue';
import '@/init-stimulus';
initApps();
console.log('Vite ⚡️ Rails ⚡️ Private');

window.addEventListener('DOMContentLoaded', function () {
  Array.from(document.getElementsByClassName('trigger-submit-form')).forEach((item) => {
    item.addEventListener('click', () => (item as HTMLFormElement).submit());
  });
});
