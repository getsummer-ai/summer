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
  fetch(`${apiUrl}/api/v1/button/version`, {
    mode: 'cors',
    headers: {
      'Content-Type': 'application/json',
      'Api-Key': key,
    },
  })
    .then((response) => response.json())
    .then((data: { message?: string; path: string }) => {
      if (!data.path) return console.error('GetSummer - ' + (data.message || 'No applications found'))
      addScript(apiUrl + data.path).catch(console.log);
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



