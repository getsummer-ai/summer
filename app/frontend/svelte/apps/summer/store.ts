import { writable } from 'svelte/store';

export type ArticleInitInfo = {
  id: string;
  title: string;
};

export type ErrorCodeType = {
  code: string;
  message: string;
};

export type SettingsInfo = {
  theme: string | null;
  paths: string[];
  features: {
    suggestion: boolean,
    subscription: boolean,
  }
};
const api_host = import.meta.env.VITE_API_URL as string;

const getFetch = async <T>(
  url: string,
  project_id: string,
  body: null | { [key: string]: string } = null,
): Promise<T> => {
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
  return getFetch<{ article: ArticleInitInfo } | ErrorCodeType>(
    `${api_host}/api/v1/button/init`,
    project_id,
    { s: url },
  );
};

export const getSummary = (project_id: string, id: string) => {
  const eventSource = new EventSource(`/api/v1/summary/stream?id=${id}&key=${project_id}`);

  const result = writable('');

  eventSource.addEventListener("message", (event) => {
    // const events = document.getElementById("events")
    // events.innerHTML += `<p>${event.data}</p>`
    // console.log(event.data);
    result.set(event.data);
  })

  eventSource.addEventListener("error", (event) => {
    if (event.eventPhase === EventSource.CLOSED) {
      eventSource.close()
      console.log("Event Source Closed")
    }
    // console.log(event);
  })
  return result;
};
