import { Controller } from '@hotwired/stimulus';

export default class ProjectFormController extends Controller {
  static targets = ['field'];
  declare readonly fieldTarget: HTMLInputElement;

  addInput(e?: PointerEvent) {
    console.log(e);
    const newNode = this.fieldTarget.cloneNode() as HTMLInputElement
    newNode.removeAttribute('id')
    newNode.value = ''
    this.insertAfter(this.fieldTarget, newNode)
  }


  insertAfter(referenceNode: HTMLElement, newNode: HTMLElement) {
    const parentNode = referenceNode.parentNode
    if (!parentNode) return
    parentNode.append(newNode)
  }
}
