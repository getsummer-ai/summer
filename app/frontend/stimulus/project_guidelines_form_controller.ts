import { Controller } from '@hotwired/stimulus';

export default class ProjectGuidelinesFormController extends Controller {
  debounceInterval: number | undefined;
  change() {
    clearTimeout(this.debounceInterval);
    this.debounceInterval = setTimeout(() => {
      (this.element as HTMLFormElement)?.requestSubmit()
    }, 1000);
  }
}
