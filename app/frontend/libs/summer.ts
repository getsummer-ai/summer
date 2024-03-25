import { initApp } from '@/svelte/apps/init-button';
// const appId = (import.meta.url.split('/').pop() || 'getsummer-app').split('.')[0];
const project = {
  id: window.GetSummer.id,
  settings: window.GetSummer.settings,
};
let previousUrl = location.href;
initApp(project, previousUrl);

new MutationObserver(function () {
  if (location.href === previousUrl) return
  // console.log('mutation init app', location.href);
  previousUrl = location.href;
  initApp(project, previousUrl, 1000);
}).observe(document, { subtree: true, childList: true });
