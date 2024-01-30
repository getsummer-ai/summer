const observeUrlChange = () => {
  let oldHref = document.location.href;
  console.log(oldHref);
  const body = document.querySelector("body");
  if (!body) return;
  const observer = new MutationObserver(() => {
    if (oldHref !== document.location.href) {
      oldHref = document.location.href;
      console.log('url changed');
    }
  });
  observer.observe(body, { childList: true, subtree: true });
};
observeUrlChange();
