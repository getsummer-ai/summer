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
  fetch(`${import.meta.env.VITE_API_URL}/api/v1/button/settings`, {
    mode: 'cors',
    headers: {
      'Content-Type': 'application/json',
      'Api-Key': key,
    },
  })
    .then((response) => response.json())
    .then((data: { message?: string; path: string; settings: object }) => {
      if (!data.path) return console.error('GetSummer - ' + (data.message || 'No applications found'))
      window.GetSummer.settings = data.settings;
      addScript(import.meta.env.VITE_ASSETS_URL + data.path).catch(console.log);
    }).catch((e) => {
      console.error(e);
      console.error('GetSummer - Failed to fetch version');
    })
};

if (window?.GetSummer?.id) {
  start(window.GetSummer.id);
} else {
  window.addEventListener("DOMContentLoaded", () => {
    if (window?.GetSummer?.id) return start(window.GetSummer.id);
    console.error('GetSummer.key is not defined');
  });
}



