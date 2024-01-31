import Summer from '@/svelte/apps/summer/Summer.svelte';
import type { SvelteComponent } from 'svelte';
import { ArticleInitInfo, initButton, SettingsInfo } from '@/svelte/apps/summer/store';

let buttonApp: SvelteComponent | undefined;

const installApp = (project: string, settings: SettingsInfo, article: ArticleInitInfo) => {
  const appId = 'getsummer-' + project;
  let appElement = document.getElementById(appId);
  if (!appElement) {
    appElement = document.createElement('div');
    appElement.id = appId;
    document.body.appendChild(appElement);
  } else if (appElement.innerHTML !== '') {
    if (buttonApp && typeof buttonApp.$destroy == 'function') buttonApp.$destroy();
    appElement.innerHTML = '';
    buttonApp = undefined;
  }
  buttonApp = new Summer({ target: appElement, props: { project, settings, article } });
};

export const initApp = (projectId: string, url: string) => {
  console.log('initApp', projectId, url);
  initButton(projectId, url).then((info) => {
    console.log(info);
    installApp(projectId, info.settings, info.article);
  });
};
