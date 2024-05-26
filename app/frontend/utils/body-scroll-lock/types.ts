export type Nullable<T> = T | Array<T> | null;

export interface LockState {
  lockedNum: number,
  lockedElements: HTMLElement[],
  unLockCallback: null | (() => void),
  /** Only add document listener once */
  documentListenerAdded: boolean,
  initialClientPos: {
    clientX: number,
    clientY: number,
  },
}

export interface BSLOptions {
  skipIfScrollbarVisuallyExists?: boolean,
}

declare global {
  interface Window {
    __BSL_LOCK_STATE__?: LockState
    __BSL_PREVENT_DEFAULT__?: (event: TouchEvent) => void
  }
}
