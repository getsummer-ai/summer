import { Controller } from '@hotwired/stimulus';
import { log } from '@/utils/common';

export default class AlertController extends Controller {
  static values = {
    persistent: Boolean
  }

  declare persistentValue: boolean;


  connect() {
    log('AlertController -- connect', this.persistentValue);
    if (!this.persistentValue) {
      setTimeout(() => this.hideAlert(), 3000)
    }
  }
  hideAlert(e?: PointerEvent) {
    // console.log('AlertController -- hideAlert');
    // console.log(e, this.element);
    if (e) e.stopPropagation();
    this.element.remove();
  }
}
