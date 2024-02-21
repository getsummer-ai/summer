import Summer from '@/svelte/apps/summer/Summer.svelte';
import type { SvelteComponent } from 'svelte';
import { ArticleInitInfo, initButton, SettingsInfo } from '@/svelte/apps/summer/store';

let buttonApp: SvelteComponent | undefined;
let checkerInterval: number | undefined;
let timeoutId: number;
const destroyApp = () => {
  if (buttonApp && typeof buttonApp.$destroy == 'function') buttonApp.$destroy();
  buttonApp = undefined;
}

const installApp = (project: string, settings: SettingsInfo, article: ArticleInitInfo) => {
  const appId = 'getsummer-' + project;
  let appElement = document.getElementById(appId);
  if (!appElement) {
    appElement = document.createElement('div');
    appElement.id = appId;
    document.body.appendChild(appElement);
  } else if (appElement.innerHTML !== '') {
    appElement.innerHTML = '';
  }
  destroyApp();
  buttonApp = new Summer({ target: appElement, props: { project, settings, article } });
  return appId;
};

export const initApp = (projectId: string, url: string, timeout = 100) => {
  clearInterval(checkerInterval);
  clearTimeout(timeoutId);

  timeoutId = setTimeout(() => {
    initButton(projectId, url).then((info) => {
      const install = () => installApp(projectId, info.settings, info.article)
      // console.log(info);
      const appId = install();
      checkerInterval = setInterval(() => {
        if (document.getElementById(appId) !== null) return;
        console.log('app destroyed, reinstalling');
        destroyApp();
        install();
      }, 2000);
    }).catch((e) => {
      console.error('initApp', e);
    });
  }, timeout);
};
