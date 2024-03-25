import { Controller } from '@hotwired/stimulus';

export default class ProjectGuidelinesFormController extends Controller {
  static targets = ['limit', 'input'];
  declare readonly limitTarget: HTMLSpanElement;
  declare readonly inputTarget: HTMLInputElement;

  debounceInterval: number | undefined;

  connect() {
    this.updateLimitTarget();
  }

  change() {
    clearTimeout(this.debounceInterval);
    this.debounceInterval = setTimeout(() => {
      (this.element as HTMLFormElement)?.requestSubmit();
    }, 2000);
    this.updateLimitTarget();
  }

  updateLimitTarget() {
    this.limitTarget.innerHTML = this.inputTarget.value.length.toString();
  }
}
