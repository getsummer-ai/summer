import { defineStore } from 'pinia';
import { LocaleType } from '@/types';

interface State {
  info: UserInfo | null;
  environment: string;
  locale: LocaleType;
}

interface UserInfo {
  name: string;
  age: number;
}

export const useUserStore = defineStore('user', {
  state: (): State => {
    return {
      info: null,
      environment: 'production',
      locale: 'en',
    };
  },
  actions: {
    retrieveDefaultSettings() {
      const initData = JSON.parse(document.body.dataset.init as string);
      this.info = { name: initData.age, age: initData.age };
      this.environment = initData.environment;
      this.locale = initData.locale;
    },
  },
});
