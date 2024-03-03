import { Controller } from '@hotwired/stimulus';
type LogArg = string | number | boolean | null | undefined | HTMLElement;
const logIsActive = false;
function log(...args: LogArg[]) {
  if (logIsActive) console.log(...args);
}

export default class TurboModalContainerController extends Controller {
  static targets = ['modal'];
  declare readonly modalTarget: HTMLDivElement;
  eventListener: (this: Window, ev: PopStateEvent) => void = () => {
    log('eventListener');
    this.openOrCloseModalBasedOnPathInUrl();
  };

  connect() {
    log('ModalContainer connect');
    this.openOrCloseModalBasedOnPathInUrl();
    window.addEventListener('popstate', this.eventListener);
  }

  disconnect() {
    log('ModalContainer disconnect');
    window.removeEventListener('popstate', this.eventListener);
  }

  openOrCloseModalBasedOnPathInUrl() {
    if (!window.Turbo) return;
    log('data-turbo-preview', document.documentElement.hasAttribute("data-turbo-preview"))
    if (document.documentElement.hasAttribute("data-turbo-preview")) return;
    const url = window.location;
    const urlParams = new URLSearchParams(url.hash.substring(1));
    const modal_url_param = urlParams.get('m');
    log('openOrCloseModalBasedOnPathInUrl', window.location.href, modal_url_param);

    if (!modal_url_param) {
      if (this.modalTarget.firstElementChild) {
        log(this.modalTarget);
        this.modalTarget.removeChild(this.modalTarget.firstElementChild);
        log('clean src');
        this.modalTarget.removeAttribute('src');
      }
      return;
    }

    try {
      const modalUrlPath = atob(modal_url_param);
      if (this.modalTarget.getAttribute('src')?.includes(modalUrlPath)) return;
      log("this.modalTarget.setAttribute('src', modalUrlPath)");
      this.modalTarget.setAttribute('src', modalUrlPath);
    } catch (error) {
      console.error(error);
    }
  }
}
