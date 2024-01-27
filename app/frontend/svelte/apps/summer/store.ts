import { writable } from 'svelte/store';

type ArticleInitInfo = {
  id: string;
  title: string;
};

type ArticleInfo = ArticleInitInfo & {
  summary: string;
}

type SettingsInfo = {
  color: string | null;
  size: string | null;
};
const api_host = 'http://summer-api.local:3000';
export const project_id = writable<string>();
export const article_info = writable<ArticleInfo>();
export const settings = writable<SettingsInfo>();

const getFetch = async <T>(url: string, project_id: string): Promise<T> => {
  const requestHeaders: HeadersInit = new Headers();
  requestHeaders.set('Content-Type', 'application/json');
  requestHeaders.set('Api-Token', project_id);
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
