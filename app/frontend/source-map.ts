import { Component, defineAsyncComponent as asyncComp } from 'vue';
import { Router, createRouter, createWebHashHistory } from 'vue-router';
import ResultsPage from '@/apps/main-app/results-page.vue';

interface AppSourceMap {
  [key: string]: {
    component: Component;
    router?: () => Router;
  };
}

export const appSourceMap: AppSourceMap = {
  'main-app': {
    component: asyncComp(() => import('@/apps/main-app.vue')),
    router: () =>
      createRouter({
        linkActiveClass: 'active',
        linkExactActiveClass: 'exact-active',
        // 4. Provide the history implementation to use. We are using the hash history for simplicity here.
        history: createWebHashHistory(),
        // history: createWebHistory(),
        routes: [
          {
            path: '/results',
            component: ResultsPage,
            meta: { transition: 'slide-right' },
          },
        ],
      }),
  },
};
