import { Controller } from '@hotwired/stimulus'

export default class AutoSubmitInputFormController extends Controller {
  static targets = ['input'];
  declare readonly inputTarget: HTMLInputElement;

  declare timeout?: number;

  connect() {
    this.timeout = undefined
  }

  debouncedSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      (this.element as HTMLFormElement).requestSubmit()
    }, 500)
  }
}
