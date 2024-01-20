import { defineStore } from 'pinia';

interface State {
  session: SessionInfo;
}

export const useSessionStore = defineStore('session', {
  state: (): State => {
    return {
      session: {
        csrfToken: '',
      },
    };
  },
});

interface SessionInfo {
  csrfToken: string;
}
