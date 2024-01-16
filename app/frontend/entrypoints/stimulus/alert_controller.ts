import { Controller } from '@hotwired/stimulus';

export default class AlertController extends Controller {
  hideAlert(e: PointerEvent) {
    // console.log('AlertController -- hideAlert');
    // console.log(e, this.element);
    e.stopPropagation();
    this.element.remove();
  }
}
