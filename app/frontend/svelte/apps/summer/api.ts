import { Writable, writable } from 'svelte/store';

export type ArticleInitInfo = {
  page_id: string;
  title: string;
};

export type ProjectServiceType = {
  uuid: string;
  link: string;
  description: string;
  title: string;
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
  theme: string | null;
  paths: string[];
  features: {
    suggestion: boolean;
    subscription: boolean;
  };
};
const api_host = import.meta.env.VITE_API_URL as string;

const getFetch = async <T>(
  url: string,
  projectId: string,
  body: null | { [key: string]: string } = null,
): Promise<ApiResponseType<T>> => {
  const response = await fetch(url, {
    method: body == null ? 'GET' : 'POST',
    mode: 'cors',
    headers: {
      'Content-Type': 'application/json',
      'Api-Key': projectId,
    },
    ...(body == null ? {} : { body: JSON.stringify(body) }),
  });
  let res = await response.text();
  if (res) {
    try {
      res = JSON.parse(res);
      return { status: response.status, body: res as T };
    } catch (e) {
      console.log(e);
    }
  }
  return { status: response.status, body: null };
};

export const initButton = async (projectId: string, url: string) => {
  return getFetch<{ article: ArticleInitInfo } | ErrorCodeType>(
    `${api_host}/api/v1/button/init`,
    projectId,
    { s: url },
  );
};

const getSummary = (projectId: string, id: string) => {
  const eventSource = new EventSource(`/api/v1/pages/${id}/summary?key=${projectId}`);
  const result = writable('');
  const isCompleted = writable(false);

  eventSource.addEventListener('message', (event) => {
    // const events = document.getElementById("events")
    // events.innerHTML += `<p>${event.data}</p>`
    // console.log(event.data);
    result.set(event.data);
    // console.log('readyState', eventSource.readyState)
  });

  eventSource.addEventListener('error', (event) => {
    if (event.eventPhase === EventSource.CLOSED) {
      eventSource.close();
      // console.log("Event Source Closed")
      isCompleted.set(true);
    }
    // console.log(event);
  });
  return { result, isCompleted };
};

const getServices = (projectId: string, pageId: string) => {
  return getFetch<{ services: ProjectServiceType[] } | ErrorCodeType>(
    `${api_host}/api/v1/pages/${pageId}/products`,
    projectId,
  );
};

const clickService = (projectId: string, pageId: string, serviceId: string) => {
  return getFetch<{ services: ProjectServiceType[] } | ErrorCodeType>(
    `${api_host}/api/v1/pages/${pageId}/products/${serviceId}/click`,
    projectId,
    {},
  );
};

const subscribe = (projectId: string, pageId: string, email: string) =>
  getFetch(`${api_host}/api/v1/pages/${pageId}/subscribe`, projectId, { email });

let initializedApi: {
  clickService: (
    pageId: string,
    serviceId: string,
  ) => Promise<ApiResponseType<ErrorCodeType | { services: ProjectServiceType[] }>>;
  getServices: (pageId: string) => Promise<ApiResponseType<ErrorCodeType | { services: ProjectServiceType[] }>>;
  getSummary: (id: string) => { result: Writable<string>; isCompleted: Writable<boolean> };
  subscribe: (pageId: string, id: string) => Promise<ApiResponseType<unknown>>;
};

export const initApi = (projectId?: string) => {
  if (!projectId && initializedApi) return initializedApi;
  if (!projectId) throw new Error('projectId is required');

  initializedApi = {
    clickService: clickService.bind(null, projectId),
    getServices: getServices.bind(null, projectId),
    getSummary: getSummary.bind(null, projectId),
    subscribe: subscribe.bind(null, projectId),
  };

  return initializedApi;
};
