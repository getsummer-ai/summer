type LogArg = string | number | boolean | null | undefined | HTMLElement;

const logIsActive = import.meta.env.VITE_SHOW_JS_LOGS === 'true';
export function log(...args: LogArg[]) {
  if (logIsActive) console.log(...args);
}

export type TurboBeforeStreamRenderEvent = CustomEvent<{
  render: (streamElement: { action: string }) => void
}>
