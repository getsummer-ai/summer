(function (o) {
  typeof define == 'function' && define.amd ? define(o) : o();
})(function () {
  'use strict';
  var s;
  function o(t) {
    return new Promise((r, n) => {
      const e = document.createElement('script');
      e.setAttribute('src', t),
        e.setAttribute('type', 'module'),
        e.setAttribute('crossorigin', 'anonymous'),
        e.addEventListener('load', r),
        e.addEventListener('error', n),
        document.head.appendChild(e);
    });
  }
  const i = (t) => {
    const r = 'http://summer-api.local:3000',
      n = new Headers();
    n.set('Content-Type', 'application/json'),
      n.set('Api-Key', t),
      fetch(`${r}/api/v1/button/version`, { mode: 'cors', headers: n })
        .then((e) => e.json())
        .then((e) => {
          o(r + e.path).catch(console.log), console.log(e);
        });
  };
  (s = window == null ? void 0 : window.GetSummer) != null && s.key
    ? i(window.GetSummer.key)
    : window.addEventListener('DOMContentLoaded', () => {
        var t;
        if (!((t = window == null ? void 0 : window.GetSummer) != null && t.key))
          return i(window.GetSummer.key);
        console.error('GetSummer.key is not defined');
      });
});
