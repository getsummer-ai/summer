import { Controller } from '@hotwired/stimulus';
export default class AutoDisableFormController extends Controller {
  static values = { with: String }

  declare hasWithValue: boolean;
  declare withValue: string;

  connect() {
    (this.element as HTMLElement).dataset['action'] = 'submit->auto-disable-form#disableForm'

    if (!this.hasWithValue) {
      this.withValue = "Processing..."
    }
  }

  disableForm() {
    this.submitButtons().forEach(button => {
      button.disabled = true
      button.textContent = this.withValue
    })
    this.submitInputs().forEach(button => {
      button.disabled = true
      button.value = this.withValue
    })
  }

  submitButtons() {
    return (this.element.querySelectorAll("button[type='submit']") as NodeListOf<HTMLInputElement>)
  }

  submitInputs() {
    return (this.element.querySelectorAll("input[type='submit']") as NodeListOf<HTMLInputElement>)
  }
}
