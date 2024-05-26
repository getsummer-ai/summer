import type { LockState } from './types'
import { isServer } from './utils'

const initialLockState: LockState = {
  lockedNum: 0,
  lockedElements: [],
  unLockCallback: null,
  documentListenerAdded: false,
  initialClientPos: {
    clientX: 0,
    clientY: 0,
  },
}

export function getLockState () {
  if (isServer()) return initialLockState

  return getLockState.lockState
}
getLockState.lockState = initialLockState
