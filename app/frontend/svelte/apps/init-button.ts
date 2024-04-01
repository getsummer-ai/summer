import Summer from '@/svelte/apps/summer/Summer.svelte';
import type { SvelteComponent } from 'svelte';
import { ArticleInitInfo, initButton, SettingsInfo } from '@/svelte/apps/summer/api';

let buttonApp: SvelteComponent | undefined;
let checkerInterval: number | undefined;
let timeoutId: number;

const log = (message: string) => {
  console.log(`%c${message}`, 'background: #FFEFE7; padding: 2px 10px;');
}
const destroyApp = () => {
  if (buttonApp && typeof buttonApp.$destroy == 'function') buttonApp.$destroy();
  buttonApp = undefined;
};

const installApp = (projectId: string, settings: SettingsInfo, article: ArticleInitInfo) => {
  const appId = 'getsummer-' + projectId;
  let appElement = document.getElementById(appId);
  if (!appElement) {
    appElement = document.createElement('div');
    appElement.id = appId;
    document.body.appendChild(appElement);
  } else if (appElement.innerHTML !== '') {
    appElement.innerHTML = '';
  }
  destroyApp();
  buttonApp = new Summer({ target: appElement, props: { projectId, settings, article } });
  return appId;
};

export const initApp = (project: { id: string; settings: object }, url: string, timeout = 100) => {
  const pathname = new URL(url).pathname;
  const settings = project.settings as SettingsInfo

  clearInterval(checkerInterval);
  clearTimeout(timeoutId);

  const path = settings.paths.find((path) => (pathname.indexOf(path) === 0))
  // console.log('initApp', path, pathname);
  if (typeof path === 'undefined') return;

  timeoutId = setTimeout(() => {

    initButton(project.id, url)
      .then((info) => {
        const body = info.body
        if (!body) return log("GetSummer: Skipping page as there's no article");
        if ('code' in body) return console.error('GetSummer', info);
        const install = () =>
          installApp(project.id, settings, body.article);
        // console.log(info);
        const appId = install();
        checkerInterval = setInterval(() => {
          if (document.getElementById(appId) !== null) return;
          console.log('app destroyed, reinstalling');
          destroyApp();
          install();
        }, 2000);
      })
      .catch((e) => {
        console.error('initApp', e);
      });
  }, timeout);
};
