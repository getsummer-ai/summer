import type { BSLOptions } from './types'

export function setOverflowHiddenPc (options?: BSLOptions) {
  const $html = document.documentElement
  const htmlStyle = { ...$html.style }
  const scrollBarWidth = window.innerWidth - $html.clientWidth
  const previousPaddingRight = parseInt(window.getComputedStyle($html).paddingRight, 10)
  const paddingRight = scrollBarWidth + previousPaddingRight

  if (options?.skipIfScrollbarVisuallyExists && paddingRight > 0) return null;

  $html.style.overflow = 'hidden'
  $html.style.boxSizing = 'border-box'
  $html.style.paddingRight = `${paddingRight}px`

  return () => {
    (['overflow', 'boxSizing', 'paddingRight'] as const).forEach((x) => {
      $html.style[x] = htmlStyle[x] || ''
    })
  }
}

export function setOverflowHiddenMobile () {
  const $html = document.documentElement
  const $body = document.body
  const scrollTop = $html.scrollTop || $body.scrollTop
  const htmlStyle = { ...$html.style }
  const bodyStyle = { ...$body.style }

  $html.style.height = '100%'
  $html.style.overflow = 'hidden'

  $body.style.top = `-${scrollTop}px`
  $body.style.width = '100%'
  $body.style.height = 'auto'
  $body.style.position = 'fixed'
  $body.style.overflow = 'hidden'

  return () => {
    $html.style.height = htmlStyle.height || ''
    $html.style.overflow = htmlStyle.overflow || ''

    ; (['top', 'width', 'height', 'overflow', 'position'] as const).forEach((x) => {
      $body.style[x] = bodyStyle[x] || ''
    })

    const supportsNativeSmoothScroll = 'scrollBehavior' in document.documentElement.style
    if (supportsNativeSmoothScroll) {
      window.scrollTo({ top: scrollTop, behavior: 'instant' } as unknown as ScrollToOptions)
    } else {
      window.scrollTo(0, scrollTop)
    }
  }
}
