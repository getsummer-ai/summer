const url = 'https://summer-api.local/api/v1/button/version';
// const script_url = 'https://summer-api.local/api/v1/button/version';
window.addEventListener('load', () => {
  fetch(url)
    .then(response => response.json())
    .then(data => {
      console.log(data);
    });
});


