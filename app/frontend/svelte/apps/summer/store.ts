// import { writable } from 'svelte/store';

export type ArticleInitInfo = {
  id: string;
  title: string;
};

export type ArticleInfo = ArticleInitInfo & {
  summary: string;
};

export type SettingsInfo = {
  color: string | null;
  size: string | null;
};
const api_host = import.meta.env.VITE_API_URL as string;
// export const project_id = writable<string>();
// export const project_id = writable<string>();
// export const article_info = writable<ArticleInfo>();
// export const settings = writable<SettingsInfo>();

const getFetch = async <T>(
  url: string,
  project_id: string,
  body: null | { [key: string]: string } = null,
): Promise<T> => {
  // const requestHeaders: HeadersInit = new Headers();
  // requestHeaders.set('Content-Type', 'application/json');
  // requestHeaders.set('Api-Key', project_id);
  const response = await fetch(url, {
    method: body == null ? 'GET' : 'POST',
    mode: 'cors',
    headers: {
      'Content-Type': 'application/json',
      'Api-Key': project_id,
    },
    ...(body == null ? {} : { body: JSON.stringify(body) }),
  });
  return response.json();
};

export const initButton = async (project_id: string, url: string) => {
  return getFetch<{ settings: SettingsInfo; article: ArticleInitInfo }>(
    `${api_host}/api/v1/button/init`,
    project_id,
    { s: url },
  );
};

export const getSummary = async (project_id: string, id: string) => {
  const info = await getFetch<{ article: ArticleInfo }>(
    `${api_host}/api/v1/button/summary?id=${encodeURIComponent(id)}`,
    project_id,
  );
  // article_info.set(info.article);
  return info;
};
