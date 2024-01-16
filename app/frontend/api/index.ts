import axios from 'axios';
import { useSessionStore } from '@/stores/sessionStore';

const instance = axios.create();
instance.interceptors.request.use(function (config) {
  config.headers['X-CSRF-Token'] = useSessionStore().session.csrfToken;
  return config;
});

export default instance;
