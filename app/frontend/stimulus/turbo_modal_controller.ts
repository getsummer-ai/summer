import { Controller } from '@hotwired/stimulus';

function setModalQueryStringParam(value: string) {
  const url = new URL(window.location.href);
  const params = url.searchParams;
  if (params.get('m') === value) return;
  params.set('m', value);
  url.search = params.toString();
  console.log('setModalQueryStringParam', url.href)
  window.Turbo.navigator.history.push(url);
}

function removeModalQueryStringParam() {
  const url = new URL(window.location.href);
  const params = url.searchParams;
  params.delete('m');
  url.search = params.toString();
  console.log('removeModalQueryStringParam', url.href);
  window.Turbo.navigator.history.push(url);
}

export default class TurboModalController extends Controller {
  static targets = ['modal'];
  static values = {
    allowRedirect: Boolean,
  };

  declare readonly modalTarget: HTMLDivElement;
  declare allowRedirectValue: boolean;

  closed = false;

  connect() {
    const src = this.element.parentElement?.getAttribute('src');
    if (!src) return;
    console.log('Modal connect', src);
    const url = new URL(src);
    setModalQueryStringParam(btoa(url.pathname));
  }

  disconnect() {
    this.closeModal();
    removeModalQueryStringParam();
    console.log('Modal disconnect');
  }

  closeModal() {
    if (this.closed) return;
    console.log('closeModal', this.element.parentElement);
    if (this.element.parentElement) {
      this.element.parentElement.removeAttribute('src');
      this.element.parentElement.focus();
      // console.log('removeAttribute src', this.element.parentElement.getAttribute('src'));
      // console.log('closeModal after removeAttribute', this.element.parentElement);
    }
    this.element.remove();
    this.closed = true;
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

  closeOnClickOutside(e: MouseEvent) {
    if (e.target && this.modalTarget.contains(e.target as Node)) return;
    this.closeModal();
  }
}
