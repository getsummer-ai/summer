// export function respondToVisibility(element: HTMLElement, callback: () => void) {
//   var options = {
//     root: document.documentElement,
//   };
//
//   const observer = new IntersectionObserver((entries, observer) => {
//     entries.forEach(entry => {
//       callback(entry.intersectionRatio > 0);
//     });
//   }, options);
//
//   observer.observe(element);
// }
//
// function onVisible(element: HTMLElement, callback: () => void) {
//   new IntersectionObserver((entries, observer) => {
//     entries.forEach(entry => {
//       if(entry.intersectionRatio > 0) {
//         callback(element);
//         observer.disconnect();
//       }
//     });
//   }).observe(element);
//   if(!callback) return new Promise(r => callback=r);
// }
