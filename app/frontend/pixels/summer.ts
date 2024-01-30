const observeUrlChange = () => {
  const oldHref = document.location.href;
  console.log(oldHref);
  window.addEventListener(
    "hashchange",
    () => {
      console.log("The hash has changed!");
    },
    false,
  );
  // const body = document.querySelector("body");
  // if (!body) return;
  // const observer = new MutationObserver(() => {
  //   console.log(document.location.href);
  //   if (oldHref !== document.location.href) {
  //     oldHref = document.location.href;
  //     console.log('url changed');
  //   }
  // });
  // observer.observe(body, { childList: true, subtree: true });
};
observeUrlChange();

let previousUrl = location.href;
const observer = new MutationObserver(function() {
  console.log('mutation', location.href);

  // If URL changes...
  if (location.href !== previousUrl) {
    previousUrl = location.href;

    // Close popup
    // removeBanner();

    // Once navigation is detected, disconnect mutation observer
    // observer.disconnect();
  }
});

// Mutation observer setup
const config = {subtree: true, childList: true};
observer.observe(document, config);
