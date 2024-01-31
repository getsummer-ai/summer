import { writable } from 'svelte/store';

export type ArticleInitInfo = {
  id: string;
  title: string;
};

export type ArticleInfo = ArticleInitInfo & {
  summary: string;
}

export type SettingsInfo = {
  color: string | null;
  size: string | null;
};
const api_host = import.meta.env.VITE_API_URL as string;
export const project_id = writable<string>();
export const article_info = writable<ArticleInfo>();
export const settings = writable<SettingsInfo>();

const getFetch = async <T>(url: string, project_id: string): Promise<T> => {
  const requestHeaders: HeadersInit = new Headers();
  requestHeaders.set('Content-Type', 'application/json');
  requestHeaders.set('Api-Key', project_id);
  const response = await fetch(url, {
    mode: 'cors',
    headers: requestHeaders,
  });
  return response.json();
};

export const initButton = async (project_id: string, url: string) => {
  const info = await getFetch<{ settings: SettingsInfo; article: ArticleInitInfo }>(
    `${api_host}/api/v1/button/init?s=${encodeURIComponent(url)}`,
    project_id,
  );
  return info;
};

export const getSummary = async (project_id: string, id: string) => {
  const info = await getFetch<{ article: ArticleInfo }>(
    `${api_host}/api/v1/button/summary?id=${encodeURIComponent(id)}`,
    project_id,
  );
  article_info.set(info.article);
  return info;
};
