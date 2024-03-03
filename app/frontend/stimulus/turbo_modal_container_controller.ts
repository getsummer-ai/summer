import { Controller } from '@hotwired/stimulus';


// let activated = false;
// let url = '';

export default class TurboModalContainerController extends Controller {
  static targets = ['modal'];
  declare readonly modalTarget: HTMLDivElement;
  eventListener: (this: Window, ev: PopStateEvent) => void = () => {
    // console.log('event', event)
    console.log('eventListener');
    // console.log(this.openOrCloseModalBasedOnPathInUrl)
    // this.openOrCloseModalBasedOnPathInUrl();
  };

  initialize() {
    console.log('ModalContainer initialize');
  }

  connect() {
    console.log('ModalContainer connect');
    this.openOrCloseModalBasedOnPathInUrl();
    // if (activated) return;
    // activated = true;
    window.addEventListener('popstate', this.eventListener);
  }

  disconnect() {
    console.log('ModalContainer disconnect');
    window.removeEventListener('popstate', this.eventListener);
  }

  openOrCloseModalBasedOnPathInUrl() {
    if (!window.Turbo) return;
    // if (url === window.location.href) return;
    // url = window.location.href;
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const modal_url_param = urlParams.get('m');
    console.log(window.location.href);
    console.log('openOrCloseModalBasedOnPathInUrl', modal_url_param);

    if (!modal_url_param) {
      console.log(this.modalTarget);
      if (this.modalTarget.firstElementChild) {
        this.modalTarget.removeChild(this.modalTarget.firstElementChild);
        console.log('clean src');
        this.modalTarget.removeAttribute('src');
        console.log('after cleaning src');
      }
      // setTimeout(() => {
      //   // this.element?.focus();
      //   document.body.click();
      // }, 500)
      return;
    }
    try {
      console.log("this.element.setAttribute('src', modalUrlPath)");
      const modalUrlPath = atob(modal_url_param);
      // window.Turbo.navigator.history.push(modalUrlPath);
      // this.modalTarget.setAttribute('src', modalUrlPath);
      window.Turbo.visit(modalUrlPath, { action: '', frame: 'modal' });
    } catch (error) {
      console.error(error);
    }
  }
}
