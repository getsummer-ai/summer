import { KeyValueType } from '@/types';

export type MessagesType<T extends KeyValueType> = {
  en: T;
  es: T;
};

export function useI18n<T extends KeyValueType>(
  messages: MessagesType<T>,
  lang: keyof MessagesType<T>,
): (key: keyof T) => keyof T | string {
  const typedMessages = defineMessages(messages);
  return (key: keyof T) => typedMessages[lang][key] || key;
}

export function defineMessages<T extends KeyValueType>(messages: MessagesType<T>) {
  return messages;
}
