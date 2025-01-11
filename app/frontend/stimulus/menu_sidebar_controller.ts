import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'
// import { lock, unlock } from '@/utils/body-scroll-lock';

export default class MenuSidebarController extends Controller {
  static targets = ['checkbox'];
  declare readonly checkboxTarget: HTMLInputElement;
  declare menu: HTMLDivElement;
  declare hidden: boolean;
  declare ableToClick: boolean;

  connect() {
    // console.log(this)
    const menu = document.getElementById('sidebar-menu')
    if (menu) this.menu = menu as HTMLDivElement;
    this.hidden = this.menu?.classList.contains('hidden') || true;
    this.ableToClick = true;
    useClickOutside(this, { element: this.menu, events: ['touchend', 'click'] });
  }

  toggleMenu(e?: PointerEvent) {
    e?.preventDefault();
    e?.stopPropagation();
    this.closeOpen();
  }

  closeOpen() {
    if (!this.ableToClick) return;
    this.ableToClick = false;

    this.checkboxTarget.checked = !this.checkboxTarget.checked;
    // this.menu.classList.toggle('hidden');
    // this.menu.classList.toggle('flex');
    // console.log(this.checkboxTarget.checked)

    if (this.checkboxTarget.checked) {
      this.menu.classList.remove('hidden');
      this.menu.classList.add('flex');
      this.menu.classList.add('shadow-2xl');
      // I'm removing the lock because it's causing a bug on mobile
      // since I have no way to unlock it when links are clicked
      // lock(this.menu);
    } else {
      this.menu.classList.add('hidden');
      this.menu.classList.remove('flex');
      this.menu.classList.remove('shadow-2xl');
      // unlock();
    }
    setTimeout(() => {
      this.ableToClick = true;
    }, 200)
  }

  clickOutside(e: PointerEvent) {
    if (!this.checkboxTarget.checked) return;
    const target = e.target as HTMLElement | null;
    // console.log(this.checkboxTarget.checked, target?.tagName, target?.parentElement?.tagName);

    const contains = this.menu.contains(target);
    const isLink = target?.tagName == 'A' || target?.parentElement?.tagName == 'A';

    if (!contains || isLink) {
      // console.log('clickOutside');
      this.closeOpen();
      if (isLink && target) {
        e.preventDefault();
        e.stopPropagation();
        if (target.tagName == 'A') return target.click();
        target.parentElement?.click();
      }
    }
  }
}
