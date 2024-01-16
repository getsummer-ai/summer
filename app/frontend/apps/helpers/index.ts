export const scrollTo = (position: number) => {
  return new Promise<void>((resolve) => {
    const scrollListener = (e: Event) => {
      if ('undefined' === typeof e) return;
      const target = e.currentTarget;
      if (!target) return;
      if ((target as Window).scrollY === position) {
        target.removeEventListener('scroll', scrollListener);
        resolve();
        console.log('scrolled');
      }
    };
    if (window.scrollY === position) return resolve();
    window.addEventListener('scroll', scrollListener);
    window.scrollTo({
      top: position,
      behavior: 'smooth',
    });
  });
};
