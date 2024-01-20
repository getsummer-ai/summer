import App from '@/svelte/apps/App.svelte';
import type { ComponentType, SvelteComponent } from 'svelte';

interface AppSourceMap {
  [key: string]: ComponentType;
}

const appSourceMap: AppSourceMap = {
  summerBtn: App,
};
const initializedApps: { [key: string]: SvelteComponent } = {};

export const initSvelteApps = () => {
  Object.keys(appSourceMap).forEach((id) => {
    const appElement = document.getElementById(id);
    if (!appElement) return;
    if (appElement.innerHTML !== '') {
      initializedApps[id].$destroy();
      appElement.innerHTML = '';
      delete initializedApps[id];
    }
    const rootProps: Record<string, unknown> = JSON.parse(appElement.dataset?.props || '{}');
    const Component = appSourceMap[id];
    if (!Component) return;
    initializedApps[id] = new Component({ target: appElement, props: rootProps });
  });
};
