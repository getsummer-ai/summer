import Summer from '@/svelte/apps/summer/Summer.svelte';
import type { SvelteComponent } from 'svelte';
import { initButton, SettingsInfo } from '@/svelte/apps/summer/api';

let buttonApp: SvelteComponent | undefined;
let checkerInterval: number | undefined;
let timeoutId: number;

const log = (message: string) => {
  console.log(`%c${message}`, 'background: #FFEFE7; padding: 2px 10px;');
};
const destroyApp = () => {
  if (buttonApp && typeof buttonApp.$destroy == 'function') buttonApp.$destroy();
  buttonApp = undefined;
};

const createAppContainer = (appId: string) => {
  const appElement = document.createElement('div');
  appElement.id = appId;
  document.body.appendChild(appElement);
  return appElement;
};

const deleteAppContainerIfExists = (appId: string) => {
  const appElement = document.getElementById(appId);
  if (!appElement) return false;

  if (appElement.innerHTML !== '') appElement.innerHTML = '';
  if (appElement.shadowRoot?.innerHTML) appElement.shadowRoot.innerHTML = '';
  appElement.remove();
  return true;
};

const isPathValid = (pathname: string, paths: string[]) => {
  const path = paths.find((path) => pathname.indexOf(path) === 0);
  return typeof path !== 'undefined';
};

export const initApp = (project: { id: string; settings: object }, url: string, timeout = 100) => {
  const appId = 'getsummer-' + project.id;
  const pathname = new URL(url).pathname;
  const settings = project.settings as SettingsInfo;

  clearInterval(checkerInterval);
  clearTimeout(timeoutId);

  deleteAppContainerIfExists(appId);
  if (!isPathValid(pathname, settings.paths)) return;

  timeoutId = setTimeout(() => {
    initButton(project.id, url)
      .then((info) => {
        const body = info.body;
        if (!body) return log("GetSummer: Skipping page as there's no article");
        if ('code' in body) return console.error('GetSummer', info);

        const install = () => {
          if (deleteAppContainerIfExists(appId)) destroyApp();
          buttonApp = new Summer({
            target: createAppContainer(appId).attachShadow({ mode: 'open' }),
            props: { projectId: project.id, settings, article: body.article },
          });
        };

        install();
        checkerInterval = setInterval(() => {
          if (document.getElementById(appId) !== null) return;
          log('GetSummer: App destroyed, reinstalling');
          destroyApp();
          install();
        }, 2000);
      })
      .catch((e) => {
        console.error('GetSummer Init App', e);
      });
  }, timeout);
};
