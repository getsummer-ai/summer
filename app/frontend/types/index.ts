export type PostRequest<K extends string, T> = {
  [key in K]?: T;
} & {
  success: boolean;
  errors?: string[];
};

export type LocaleType = 'en' | 'es';

export type KeyValueType = {
  [key: string]: string;
};
