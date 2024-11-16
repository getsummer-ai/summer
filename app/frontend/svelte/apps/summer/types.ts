import { MessagesType } from '@/svelte/apps/helpers/use-i18n';

export type ArticleInitInfo = {
  page_id: string;
  title: string;
};

export type ProjectProductType = {
  uuid: string;
  link: string;
  description: string;
  name: string;
  icon: string | null;
};

export type ApiResponseType<T> = {
  status: number;
  body: T | null;
};

export type ErrorCodeType = {
  code: string;
  message: string;
};

export type SettingsInfo = {
  paths: string[];
  lang: keyof MessagesType<{ [key: string]: string }>;
  appearance: {
    button_theme: 'white' | 'black';
    frame_theme: 'white' | 'black';
    z_index: number;
  };
  features: {
    suggestion: boolean;
    subscription: boolean;
  };
};
