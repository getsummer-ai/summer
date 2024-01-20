import { App, Component, createApp, defineAsyncComponent as asyncComp } from 'vue';
import { createRouter, createWebHashHistory, Router } from 'vue-router';
import { createNotivue } from 'notivue';
import { VueQueryPlugin } from 'vue-query';
import { pinia } from './stores';
import { useUserStore } from './stores/userStore';
import { useSessionStore } from './stores/sessionStore';
import ResultsPage from '@/vue/apps/main-app/ResultsPage.vue';

// eslint-disable-next-line import/no-unresolved
import 'notivue/notifications.css';
// eslint-disable-next-line import/no-unresolved
import 'notivue/animations.css';
import 'vue3-side-panel/dist/vue3-side-panel.css';

const globalProperties = {};

interface VueAppSourceMap {
  [key: string]: {
    component: Component;
    router?: () => Router;
  };
}

const appSourceMap: VueAppSourceMap = {
  'main-app': {
    component: asyncComp(() => import('./MainApp.vue')),
    router: () =>
      createRouter({
        linkActiveClass: 'active',
        linkExactActiveClass: 'exact-active',
        history: createWebHashHistory(),
        routes: [
          {
            path: '/',
            component: { render: () => null },
          },
          {
            path: '/results',
            component: ResultsPage,
            meta: { transition: 'slide-right' },
          },
        ],
      }),
  },
};

const setupApp = (app: App<Element>, router: Router | null, id = '#app') => {
  if (router) app.use(router);
  app.use(pinia);
  app.use(VueQueryPlugin);
  const notivue = createNotivue();
  app.use(notivue, { position: 'bottom-right', pauseOnHover: false, limit: 20 });
  app.config.globalProperties = { ...app.config.globalProperties, ...globalProperties };
  app.mount(id);
};

const initStore = () => {
  const userStore = useUserStore();
  userStore.retrieveDefaultSettings();
  if (userStore.environment !== 'test') {
    const csrfToken = (document.getElementsByName('csrf-token')[0] as HTMLMetaElement)?.content;
    if (!csrfToken) throw new Error('CSRF token not found');
    useSessionStore().session = { csrfToken };
  }
};

export const initApps = () => {
  // console.log('initVueApps');
  let appInstalled = false;
  Object.keys(appSourceMap).map((id) => {
    const appElement = document.getElementById(id);
    if (!appElement) return;
    const rootProps: Record<string, unknown> = JSON.parse(appElement.dataset?.props || '{}');
    const settings = appSourceMap[id];
    if (!settings) return;
    const router = settings.router ? settings.router() : null;
    const vueApp = createApp(settings.component, rootProps);
    setupApp(vueApp, router, `#${id}`);
    appInstalled = true;
  });

  if (appInstalled) initStore();
};
