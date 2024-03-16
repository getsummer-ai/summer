import { Controller } from '@hotwired/stimulus';
import { useClickOutside } from 'stimulus-use'

type LogArg = string | number | boolean | null | undefined | HTMLElement;
const logIsActive = false;
function log(...args: LogArg[]) {
  if (logIsActive) console.log(...args);
}

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
  const scrollPosition = window.scrollY
  window.location.hash = hash.toString();
  window.history.replaceState(window.history.state, '', window.location.href.split('#')[0]);
  window.scroll(0, scrollPosition)
  log('removeModalQueryStringParam END', window.location.href);
}

export default class TurboModalController extends Controller {
  static targets = ['modal'];
  static values = {
    allowRedirect: Boolean,
  };

  declare readonly modalTarget: HTMLDivElement;
  declare allowRedirectValue: boolean;

  connect() {
    useClickOutside(this, { element: this.modalTarget, events: ['touchend', 'mousedown']});
    const src = this.element.parentElement?.getAttribute('src');
    if (!src) return;
    log('Modal connect', src);
    const url = new URL(src);
    setModalQueryStringParam(btoa(url.pathname));
  }

  disconnect() {
    // if (!this.element.parentElement) return log('Modal has benn disconnected without cleaning');
    this.closeModal(false);
    log('Modal disconnect');
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
    this.element.remove();
  }

  submitEnd(e: {
    detail: { fetchResponse: { location: URL; redirected: boolean }; success: boolean };
  }) {
    // console.log('TurboModalController -- submitEnd', e);
    if (!this.allowRedirectValue) return;
    if (!e.detail.success) return;
    this.closeModal();
    if (e.detail.fetchResponse.redirected) {
      window.location.href = e.detail.fetchResponse.location.href;
    }
  }

  closeOnEscape(e: KeyboardEvent) {
    if (e.code == 'Escape') this.closeModal();
  }

  // closeOnClickOutside(e: MouseEvent) {
  //   if (e.target && this.modalTarget.contains(e.target as Node)) return;
  //   this.closeModal();
  // }
}
