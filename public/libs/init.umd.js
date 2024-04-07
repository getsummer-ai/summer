(function (o) {
  typeof define == 'function' && define.amd ? define(o) : o();
})(function () {
  'use strict';
  var s;
  function o(t) {
    return new Promise((i, e) => {
      const n = document.createElement('script');
      n.setAttribute('src', t),
        n.setAttribute('type', 'module'),
        n.setAttribute('crossorigin', 'anonymous'),
        n.addEventListener('load', i),
        n.addEventListener('error', e),
        document.head.appendChild(n);
    });
  }
  const r = (t) => {
    const i = 'http://summer-api.local:3000';
    fetch(`${i}/api/v1/button/settings`, {
      mode: 'cors',
      headers: { 'Content-Type': 'application/json', 'Api-Key': t },
    })
      .then((e) => e.json())
      .then((e) => {
        if (!e.path) return console.error('GetSummer - ' + (e.message || 'No applications found'));
        (window.GetSummer.settings = e.settings), o(i + e.path).catch(console.log);
      })
      .catch((e) => {
        console.error(e), console.error('GetSummer - Failed to fetch version');
      });
  };
  (s = window == null ? void 0 : window.GetSummer) != null && s.id
    ? r(window.GetSummer.id)
    : window.addEventListener('DOMContentLoaded', () => {
        var t;
        if ((t = window == null ? void 0 : window.GetSummer) != null && t.id)
          return r(window.GetSummer.id);
        console.error('GetSummer.key is not defined');
      });
});
