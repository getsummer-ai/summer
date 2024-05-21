import { Controller } from '@hotwired/stimulus';
import { useClickOutside } from 'stimulus-use';
import { lock, unlock } from 'tua-body-scroll-lock';
import type { TurboBeforeStreamRenderEvent } from '@/utils/common';
import { log } from '@/utils/common';

function setModalQueryStringParam(value: string) {
  const url = window.location;
  const hash = new URLSearchParams(url.hash.substring(1));
  if (hash.get('m') === value) return;
  hash.set('m', value);
  log('setModalQueryStringParam START', window.location.href);
  window.location.hash = hash.toString();
  log('setModalQueryStringParam END', window.location.href);
}

function removeModalQueryStringParam() {
  const url = window.location;
  const hash = new URLSearchParams(url.hash.substring(1));
  if (hash.get('m') === null) return;
  hash.delete('m');
  log('removeModalQueryStringParam START', window.location.href);
  const scrollPosition = window.scrollY;
  window.location.hash = hash.toString();
  window.history.replaceState(window.history.state, '', window.location.href.split('#')[0]);
  window.scroll(0, scrollPosition);
  log('removeModalQueryStringParam END', window.location.href);
}

export default class TurboModalController extends Controller {
  static targets = ['modal'];
  static values = {
    allowRedirect: Boolean,
    allowHashChanges: Boolean,
  };

  declare readonly modalTarget: HTMLDivElement;
  declare allowRedirectValue: boolean;
  declare allowHashChangesValue: boolean;

  localStreamRenderEvent: (e: Event) => void = () => {};

  connect() {
    useClickOutside(this, { element: this.modalTarget, events: ['touchend', 'mouseup'] });
    const src = this.element.parentElement?.getAttribute('src');
    if (!src) return;
    log('Modal connect', src);
    this.localStreamRenderEvent = this.beforeStreamRender.bind(this);
    window.removeEventListener('turbo:before-stream-render', this.localStreamRenderEvent);
    window.addEventListener('turbo:before-stream-render', this.localStreamRenderEvent);
    lock(this.modalTarget);
    if (!this.allowHashChangesValue) return;

    const url = new URL(src);
    setModalQueryStringParam(btoa(url.pathname));
  }

  disconnect() {
    // if (!this.element.parentElement) return log('Modal has benn disconnected without cleaning');
    this.closeModal(false);
    log('Modal disconnect');
    window.removeEventListener('turbo:before-stream-render', this.localStreamRenderEvent);
  }

  closeModal(cleanQueryStringParam = true) {
    log('cleanQueryStringParam', cleanQueryStringParam);
    if (cleanQueryStringParam) removeModalQueryStringParam();
    log('closeModal', this.element.parentElement);
    if (this.element.parentElement) {
      this.element.parentElement.removeAttribute('src');
      // this.element.parentElement.removeAttribute('complete');
      this.element.parentElement.focus();
    }
    unlock(this.modalTarget);
    this.element.remove();
  }

  submitEnd(
    e: Event & {
      detail: { fetchResponse: { location: URL; redirected: boolean }; success: boolean };
    },
  ) {
    // console.log('TurboModalController -- submitEnd', e);
    if (!this.allowRedirectValue || !e.detail.success || !e.detail.fetchResponse.redirected) return;
    this.closeModal();
    const visit_fn = window?.Turbo?.visit;
    if (typeof visit_fn == 'function') return visit_fn(e.detail.fetchResponse.location.href);
    window.location.href = e.detail.fetchResponse.location.href;
  }

  beforeStreamRender(e: Event) {
    const res = e as TurboBeforeStreamRenderEvent;
    const fallbackToDefaultActions = res.detail.render;

    res.detail.render = (streamElement) => {
      log('beforeStreamRender - streamElement.action - ', streamElement.action);
      if (streamElement.action == 'del-hash-from-history') {
        window.history.replaceState(window.history.state, '', window.location.href.split('#')[0]);
        return;
      }
      if (streamElement.action == 'close-modal') return this.closeModal();
      if (streamElement.action == 'refresh') this.closeModal();
      fallbackToDefaultActions(streamElement);
    };
  }

  closeOnEscape(e: KeyboardEvent) {
    if (e.code != 'Escape') return;
    this.closeModal();
  }
}
