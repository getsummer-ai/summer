import App from '@/svelte/apps/App.svelte';
import Summer from '@/svelte/apps/Summer.svelte';
import SummerArticlePreview from '@/svelte/apps/SummerArticlePreview.svelte';
import type { ComponentType, SvelteComponent } from 'svelte';

interface AppSourceMap {
  [key: string]: ComponentType;
}

const appSourceMap: AppSourceMap = {
  app: App,
  summer: Summer,
  'preview-summary-with-article': SummerArticlePreview,
};
const initializedApps: { [key: string]: SvelteComponent } = {};

export const initSvelteApps = (reload = true) => {
  Object.keys(appSourceMap).forEach((id) => {
    const appElement = document.getElementById(id);
    if (!appElement) return;
    if (appElement.innerHTML !== '') {
      if (!reload) return;
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

export const initializeUncreatedApps = () => {


}
