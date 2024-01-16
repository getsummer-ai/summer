import { KeyValueType } from '@/types';
import { useUserStore } from '@/stores/userStore';

type MessagesType<T extends KeyValueType> = {
  en: T;
  es: T;
};

// const locale = computed(() => useUserStore().lang);

export function useI18n<T extends KeyValueType>(
  messages: MessagesType<T>,
): (key: keyof T) => keyof T | string {
  const typedMessages = defineMessages(messages);
  const userStore = useUserStore();
  return (key: keyof T) => typedMessages[userStore.locale][key] || key;
}

export function defineMessages<T extends KeyValueType>(messages: MessagesType<T>) {
  return messages;
}
