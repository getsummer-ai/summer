import { Controller } from '@hotwired/stimulus';

export default class TurboModalController extends Controller {
  static targets = ['modal'];
  static values = {
    allowRedirect: Boolean,
  };

  declare readonly modalTarget: HTMLDivElement;
  declare allowRedirectValue: boolean;

  closeModal() {
    console.log('TurboModalController -- closeModal');
    if (!this.element.parentElement) return;
    this.element.parentElement.removeAttribute('src');
    this.element.remove();
  }

  submitEnd(e: {
    detail: { fetchResponse: { location: URL; redirected: boolean }; success: boolean };
  }) {
    console.log('TurboModalController -- submitEnd', e);
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
