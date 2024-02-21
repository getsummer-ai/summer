import {initApp} from "@/svelte/apps/init-button";
// const appId = (import.meta.url.split('/').pop() || 'getsummer-app').split('.')[0];
const projectId = window.GetSummer.key;
let previousUrl = location.href;
initApp(projectId, previousUrl);
// const a = 1;
const observer = new MutationObserver(function() {
  if (location.href !== previousUrl) {
    console.log('mutation init app', location.href)
    previousUrl = location.href;
    initApp(projectId, previousUrl, 1000);
  }
});

// Mutation observer setup
const config = {subtree: true, childList: true};
observer.observe(document, config);


