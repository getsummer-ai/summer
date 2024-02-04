function addScript(src: string) {
  return new Promise((resolve, reject) => {
    const s = document.createElement('script');
    s.setAttribute('src', src);
    s.setAttribute('type', 'module');
    s.setAttribute('crossorigin', 'anonymous');
    s.addEventListener('load', resolve);
    s.addEventListener('error', reject);
    document.head.appendChild(s);
  });
}

const start = (key: string) => {
  const apiUrl = import.meta.env.VITE_API_URL as string;
  const requestHeaders: HeadersInit = new Headers();
  requestHeaders.set('Content-Type', 'application/json');
  requestHeaders.set('Api-Key', key);
  fetch(`${apiUrl}/api/v1/button/version`, {
    mode: 'cors',
    headers: requestHeaders,
  })
    .then((response) => response.json())
    .then((data: { path: string }) => {
      addScript(apiUrl + data.path).catch(console.log);
      console.log(data);
    });
};

if (window?.GetSummer?.key) {
  start(window.GetSummer.key);
} else {
  window.addEventListener("DOMContentLoaded", () => {
    if (window?.GetSummer?.key) return start(window.GetSummer.key);
    console.error('GetSummer.key is not defined');
  });
}



