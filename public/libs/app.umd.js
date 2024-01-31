(function (m) {
  typeof define == 'function' && define.amd ? define(m) : m();
})(function () {
  'use strict';
  var ie = Object.defineProperty;
  var re = (m, y, E) =>
    y in m ? ie(m, y, { enumerable: !0, configurable: !0, writable: !0, value: E }) : (m[y] = E);
  var x = (m, y, E) => (re(m, typeof y != 'symbol' ? y + '' : y, E), E);
  function m() {}
  function y(t, e) {
    for (const n in e) t[n] = e[n];
    return t;
  }
  function E(t) {
    return t();
  }
  function tt() {
    return Object.create(null);
  }
  function N(t) {
    t.forEach(E);
  }
  function et(t) {
    return typeof t == 'function';
  }
  function R(t, e) {
    return t != t ? e == e : t !== e || (t && typeof t == 'object') || typeof t == 'function';
  }
  function mt(t) {
    return Object.keys(t).length === 0;
  }
  function nt(t, e, n, o) {
    if (t) {
      const s = ot(t, e, n, o);
      return t[0](s);
    }
  }
  function ot(t, e, n, o) {
    return t[1] && o ? y(n.ctx.slice(), t[1](o(e))) : n.ctx;
  }
  function st(t, e, n, o) {
    if (t[2] && o) {
      const s = t[2](o(n));
      if (e.dirty === void 0) return s;
      if (typeof s == 'object') {
        const l = [],
          c = Math.max(e.dirty.length, s.length);
        for (let u = 0; u < c; u += 1) l[u] = e.dirty[u] | s[u];
        return l;
      }
      return e.dirty | s;
    }
    return e.dirty;
  }
  function it(t, e, n, o, s, l) {
    if (s) {
      const c = ot(e, n, o, l);
      t.p(c, s);
    }
  }
  function rt(t) {
    if (t.ctx.length > 32) {
      const e = [],
        n = t.ctx.length / 32;
      for (let o = 0; o < n; o++) e[o] = -1;
      return e;
    }
    return -1;
  }
  function _(t, e) {
    t.appendChild(e);
  }
  function lt(t, e, n) {
    const o = _t(t);
    if (!o.getElementById(e)) {
      const s = p('style');
      (s.id = e), (s.textContent = n), pt(o, s);
    }
  }
  function _t(t) {
    if (!t) return document;
    const e = t.getRootNode ? t.getRootNode() : t.ownerDocument;
    return e && e.host ? e : t.ownerDocument;
  }
  function pt(t, e) {
    return _(t.head || t, e), e.sheet;
  }
  function v(t, e, n) {
    t.insertBefore(e, n || null);
  }
  function b(t) {
    t.parentNode && t.parentNode.removeChild(t);
  }
  function p(t) {
    return document.createElement(t);
  }
  function gt(t) {
    return document.createElementNS('http://www.w3.org/2000/svg', t);
  }
  function D(t) {
    return document.createTextNode(t);
  }
  function $() {
    return D(' ');
  }
  function T(t, e, n, o) {
    return t.addEventListener(e, n, o), () => t.removeEventListener(e, n, o);
  }
  function wt(t) {
    return function (e) {
      return e.stopPropagation(), t.call(this, e);
    };
  }
  function bt(t) {
    return function (e) {
      e.target === this && t.call(this, e);
    };
  }
  function k(t, e, n) {
    n == null ? t.removeAttribute(e) : t.getAttribute(e) !== n && t.setAttribute(e, n);
  }
  function yt(t) {
    return Array.from(t.childNodes);
  }
  function vt(t, e) {
    (e = '' + e), t.data !== e && (t.data = e);
  }
  class $t {
    constructor(e = !1) {
      x(this, 'is_svg', !1);
      x(this, 'e');
      x(this, 'n');
      x(this, 't');
      x(this, 'a');
      (this.is_svg = e), (this.e = this.n = null);
    }
    c(e) {
      this.h(e);
    }
    m(e, n, o = null) {
      this.e ||
        (this.is_svg
          ? (this.e = gt(n.nodeName))
          : (this.e = p(n.nodeType === 11 ? 'TEMPLATE' : n.nodeName)),
        (this.t = n.tagName !== 'TEMPLATE' ? n : n.content),
        this.c(e)),
        this.i(o);
    }
    h(e) {
      (this.e.innerHTML = e),
        (this.n = Array.from(
          this.e.nodeName === 'TEMPLATE' ? this.e.content.childNodes : this.e.childNodes,
        ));
    }
    i(e) {
      for (let n = 0; n < this.n.length; n += 1) v(this.t, this.n[n], e);
    }
    p(e) {
      this.d(), this.h(e), this.i(this.a);
    }
    d() {
      this.n.forEach(b);
    }
  }
  let O;
  function P(t) {
    O = t;
  }
  function kt() {
    if (!O) throw new Error('Function called outside component initialization');
    return O;
  }
  function Et(t) {
    kt().$$.on_mount.push(t);
  }
  function Mt(t, e) {
    const n = t.$$.callbacks[e.type];
    n && n.slice().forEach((o) => o.call(this, e));
  }
  const A = [],
    U = [];
  let L = [];
  const F = [],
    xt = Promise.resolve();
  let V = !1;
  function Ct() {
    V || ((V = !0), xt.then(ct));
  }
  function G(t) {
    L.push(t);
  }
  function Nt(t) {
    F.push(t);
  }
  const K = new Set();
  let S = 0;
  function ct() {
    if (S !== 0) return;
    const t = O;
    do {
      try {
        for (; S < A.length; ) {
          const e = A[S];
          S++, P(e), Tt(e.$$);
        }
      } catch (e) {
        throw ((A.length = 0), (S = 0), e);
      }
      for (P(null), A.length = 0, S = 0; U.length; ) U.pop()();
      for (let e = 0; e < L.length; e += 1) {
        const n = L[e];
        K.has(n) || (K.add(n), n());
      }
      L.length = 0;
    } while (A.length);
    for (; F.length; ) F.pop()();
    (V = !1), K.clear(), P(t);
  }
  function Tt(t) {
    if (t.fragment !== null) {
      t.update(), N(t.before_update);
      const e = t.dirty;
      (t.dirty = [-1]), t.fragment && t.fragment.p(t.ctx, e), t.after_update.forEach(G);
    }
  }
  function At(t) {
    const e = [],
      n = [];
    L.forEach((o) => (t.indexOf(o) === -1 ? e.push(o) : n.push(o))), n.forEach((o) => o()), (L = e);
  }
  const q = new Set();
  let C;
  function Lt() {
    C = { r: 0, c: [], p: C };
  }
  function St() {
    C.r || N(C.c), (C = C.p);
  }
  function M(t, e) {
    t && t.i && (q.delete(t), t.i(e));
  }
  function j(t, e, n, o) {
    if (t && t.o) {
      if (q.has(t)) return;
      q.add(t),
        C.c.push(() => {
          q.delete(t), o && (n && t.d(1), o());
        }),
        t.o(e);
    } else o && o();
  }
  function jt(t, e, n) {
    const o = t.$$.props[e];
    o !== void 0 && ((t.$$.bound[o] = n), n(t.$$.ctx[o]));
  }
  function ut(t) {
    t && t.c();
  }
  function J(t, e, n) {
    const { fragment: o, after_update: s } = t.$$;
    o && o.m(e, n),
      G(() => {
        const l = t.$$.on_mount.map(E).filter(et);
        t.$$.on_destroy ? t.$$.on_destroy.push(...l) : N(l), (t.$$.on_mount = []);
      }),
      s.forEach(G);
  }
  function Q(t, e) {
    const n = t.$$;
    n.fragment !== null &&
      (At(n.after_update),
      N(n.on_destroy),
      n.fragment && n.fragment.d(e),
      (n.on_destroy = n.fragment = null),
      (n.ctx = []));
  }
  function Ht(t, e) {
    t.$$.dirty[0] === -1 && (A.push(t), Ct(), t.$$.dirty.fill(0)),
      (t.$$.dirty[(e / 31) | 0] |= 1 << e % 31);
  }
  function W(t, e, n, o, s, l, c = null, u = [-1]) {
    const d = O;
    P(t);
    const r = (t.$$ = {
      fragment: null,
      ctx: [],
      props: l,
      update: m,
      not_equal: s,
      bound: tt(),
      on_mount: [],
      on_destroy: [],
      on_disconnect: [],
      before_update: [],
      after_update: [],
      context: new Map(e.context || (d ? d.$$.context : [])),
      callbacks: tt(),
      dirty: u,
      skip_bound: !1,
      root: e.target || d.$$.root,
    });
    c && c(r.root);
    let i = !1;
    if (
      ((r.ctx = n
        ? n(t, e.props || {}, (f, a, ...z) => {
            const g = z.length ? z[0] : a;
            return (
              r.ctx &&
                s(r.ctx[f], (r.ctx[f] = g)) &&
                (!r.skip_bound && r.bound[f] && r.bound[f](g), i && Ht(t, f)),
              a
            );
          })
        : []),
      r.update(),
      (i = !0),
      N(r.before_update),
      (r.fragment = o ? o(r.ctx) : !1),
      e.target)
    ) {
      if (e.hydrate) {
        const f = yt(e.target);
        r.fragment && r.fragment.l(f), f.forEach(b);
      } else r.fragment && r.fragment.c();
      e.intro && M(t.$$.fragment), J(t, e.target, e.anchor), ct();
    }
    P(d);
  }
  class X {
    constructor() {
      x(this, '$$');
      x(this, '$$set');
    }
    $destroy() {
      Q(this, 1), (this.$destroy = m);
    }
    $on(e, n) {
      if (!et(n)) return m;
      const o = this.$$.callbacks[e] || (this.$$.callbacks[e] = []);
      return (
        o.push(n),
        () => {
          const s = o.indexOf(n);
          s !== -1 && o.splice(s, 1);
        }
      );
    }
    $set(e) {
      this.$$set && !mt(e) && ((this.$$.skip_bound = !0), this.$$set(e), (this.$$.skip_bound = !1));
    }
  }
  const zt = '4';
  typeof window < 'u' && (window.__svelte || (window.__svelte = { v: new Set() })).v.add(zt);
  const H = [];
  function It(t, e = m) {
    let n;
    const o = new Set();
    function s(u) {
      if (R(t, u) && ((t = u), n)) {
        const d = !H.length;
        for (const r of o) r[1](), H.push(r, t);
        if (d) {
          for (let r = 0; r < H.length; r += 2) H[r][0](H[r + 1]);
          H.length = 0;
        }
      }
    }
    function l(u) {
      s(u(t));
    }
    function c(u, d = m) {
      const r = [u, d];
      return (
        o.add(r),
        o.size === 1 && (n = e(s, l) || m),
        u(t),
        () => {
          o.delete(r), o.size === 0 && n && (n(), (n = null));
        }
      );
    }
    return { set: s, update: l, subscribe: c };
  }
  const ft = 'http://summer-api.local:3000',
    Ot = It(),
    at = async (t, e) => {
      const n = new Headers();
      return (
        n.set('Content-Type', 'application/json'),
        n.set('Api-Key', e),
        (await fetch(t, { mode: 'cors', headers: n })).json()
      );
    },
    Pt = async (t, e) => await at(`${ft}/api/v1/button/init?s=${encodeURIComponent(e)}`, t),
    Bt = async (t, e) => {
      const n = await at(`${ft}/api/v1/button/summary?id=${encodeURIComponent(e)}`, t);
      return Ot.set(n.article), n;
    };
  function Rt(t) {
    let e, n, o, s, l;
    return {
      c() {
        (e = p('button')), (n = D('count is ')), (o = D(t[0]));
      },
      m(c, u) {
        v(c, e, u), _(e, n), _(e, o), s || ((l = T(e, 'click', t[1])), (s = !0));
      },
      p(c, [u]) {
        u & 1 && vt(o, c[0]);
      },
      i: m,
      o: m,
      d(c) {
        c && b(e), (s = !1), l();
      },
    };
  }
  function Ut(t, e, n) {
    let o = 0;
    return [
      o,
      () => {
        n(0, (o += 1));
      },
    ];
  }
  class qt extends X {
    constructor(e) {
      super(), W(this, e, Ut, Rt, R, {});
    }
  }
  function Dt(t) {
    lt(
      t,
      'svelte-w32227',
      'dialog.svelte-w32227.svelte-w32227{max-width:32em;border-radius:0.2em;border:none;padding:0}dialog.svelte-w32227.svelte-w32227::backdrop{background:rgba(0, 0, 0, 0.3)}dialog.svelte-w32227>div.svelte-w32227{padding:1em}dialog[open].svelte-w32227.svelte-w32227{animation:svelte-w32227-zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)}@keyframes svelte-w32227-zoom{from{transform:scale(0.95)}to{transform:scale(1)}}dialog[open].svelte-w32227.svelte-w32227::backdrop{animation:svelte-w32227-fade 0.2s ease-out}@keyframes svelte-w32227-fade{from{opacity:0}to{opacity:1}}button.svelte-w32227.svelte-w32227{display:block}',
    );
  }
  const Ft = (t) => ({}),
    dt = (t) => ({});
  function Vt(t) {
    let e, n, o, s, l, c, u, d, r, i, f, a;
    const z = t[3].header,
      g = nt(z, t, t[2], dt),
      Z = t[3].default,
      w = nt(Z, t, t[2], null);
    return {
      c() {
        (e = p('dialog')),
          (n = p('div')),
          g && g.c(),
          (o = $()),
          (s = p('hr')),
          (l = $()),
          w && w.c(),
          (c = $()),
          (u = p('hr')),
          (d = $()),
          (r = p('button')),
          (r.textContent = 'close modal'),
          (r.autofocus = !0),
          k(r, 'class', 'svelte-w32227'),
          k(n, 'class', 'svelte-w32227'),
          k(e, 'class', 'svelte-w32227');
      },
      m(h, I) {
        v(h, e, I),
          _(e, n),
          g && g.m(n, null),
          _(n, o),
          _(n, s),
          _(n, l),
          w && w.m(n, null),
          _(n, c),
          _(n, u),
          _(n, d),
          _(n, r),
          t[6](e),
          (i = !0),
          r.focus(),
          f ||
            ((a = [
              T(r, 'click', t[5]),
              T(n, 'click', wt(t[4])),
              T(e, 'close', t[7]),
              T(e, 'click', bt(t[8])),
            ]),
            (f = !0));
      },
      p(h, [I]) {
        g && g.p && (!i || I & 4) && it(g, z, h, h[2], i ? st(z, h[2], I, Ft) : rt(h[2]), dt),
          w && w.p && (!i || I & 4) && it(w, Z, h, h[2], i ? st(Z, h[2], I, null) : rt(h[2]), null);
      },
      i(h) {
        i || (M(g, h), M(w, h), (i = !0));
      },
      o(h) {
        j(g, h), j(w, h), (i = !1);
      },
      d(h) {
        h && b(e), g && g.d(h), w && w.d(h), t[6](null), (f = !1), N(a);
      },
    };
  }
  function Gt(t, e, n) {
    let { $$slots: o = {}, $$scope: s } = e,
      { showModal: l } = e,
      c;
    function u(a) {
      Mt.call(this, t, a);
    }
    const d = () => c.close();
    function r(a) {
      U[a ? 'unshift' : 'push'](() => {
        (c = a), n(1, c);
      });
    }
    const i = () => n(0, (l = !1)),
      f = () => c.close();
    return (
      (t.$$set = (a) => {
        'showModal' in a && n(0, (l = a.showModal)), '$$scope' in a && n(2, (s = a.$$scope));
      }),
      (t.$$.update = () => {
        t.$$.dirty & 3 && c && l && c.showModal();
      }),
      [l, c, s, o, u, d, r, i, f]
    );
  }
  class Kt extends X {
    constructor(e) {
      super(), W(this, e, Gt, Vt, R, { showModal: 0 }, Dt);
    }
  }
  function Jt(t) {
    lt(
      t,
      'svelte-pbmp55',
      '.button-text-xl.svelte-pbmp55{font-size:1.25rem;line-height:1.75rem}.read-the-docs.svelte-pbmp55{color:#888}',
    );
  }
  function ht(t) {
    let e, n, o, s, l, c, u;
    function d(i) {
      t[6](i);
    }
    let r = { $$slots: { header: [Wt], default: [Qt] }, $$scope: { ctx: t } };
    return (
      t[0] !== void 0 && (r.showModal = t[0]),
      (o = new Kt({ props: r })),
      U.push(() => jt(o, 'showModal', d)),
      {
        c() {
          (e = p('button')), (e.textContent = 'show modal'), (n = $()), ut(o.$$.fragment);
        },
        m(i, f) {
          v(i, e, f), v(i, n, f), J(o, i, f), (l = !0), c || ((u = T(e, 'click', t[5])), (c = !0));
        },
        p(i, f) {
          const a = {};
          f & 130 && (a.$$scope = { dirty: f, ctx: i }),
            !s && f & 1 && ((s = !0), (a.showModal = i[0]), Nt(() => (s = !1))),
            o.$set(a);
        },
        i(i) {
          l || (M(o.$$.fragment, i), (l = !0));
        },
        o(i) {
          j(o.$$.fragment, i), (l = !1);
        },
        d(i) {
          i && (b(e), b(n)), Q(o, i), (c = !1), u();
        },
      }
    );
  }
  function Qt(t) {
    let e, n, o;
    return {
      c() {
        (e = new $t(!1)),
          (n = $()),
          (o = p('a')),
          (o.textContent = 'merriam-webster.com'),
          (e.a = n),
          k(o, 'href', 'https://www.merriam-webster.com/dictionary/modal');
      },
      m(s, l) {
        e.m(t[1], s, l), v(s, n, l), v(s, o, l);
      },
      p(s, l) {
        l & 2 && e.p(s[1]);
      },
      d(s) {
        s && (e.d(), b(n), b(o));
      },
    };
  }
  function Wt(t) {
    let e;
    return {
      c() {
        (e = p('h2')),
          (e.innerHTML = `modal
        <small><em>adjective</em> mod·al \\ˈmō-dəl\\</small>`),
          k(e, 'slot', 'header');
      },
      m(n, o) {
        v(n, e, o);
      },
      p: m,
      d(n) {
        n && b(e);
      },
    };
  }
  function Xt(t) {
    let e, n, o, s, l, c, u, d, r;
    l = new qt({});
    let i = t[1] && ht(t);
    return {
      c() {
        (e = p('div')),
          (n = p('h1')),
          (n.textContent = 'Hello!'),
          (o = $()),
          (s = p('div')),
          ut(l.$$.fragment),
          (c = $()),
          i && i.c(),
          (u = $()),
          (d = p('p')),
          (d.textContent = 'Click on the Vite and Svelte logos to learn more'),
          k(n, 'class', 'button-text-xl svelte-pbmp55'),
          k(s, 'class', 'card'),
          k(d, 'class', 'read-the-docs svelte-pbmp55'),
          k(e, 'class', 'bg-black text-white');
      },
      m(f, a) {
        v(f, e, a),
          _(e, n),
          _(e, o),
          _(e, s),
          J(l, s, null),
          _(e, c),
          i && i.m(e, null),
          _(e, u),
          _(e, d),
          (r = !0);
      },
      p(f, [a]) {
        f[1]
          ? i
            ? (i.p(f, a), a & 2 && M(i, 1))
            : ((i = ht(f)), i.c(), M(i, 1), i.m(e, u))
          : i &&
            (Lt(),
            j(i, 1, 1, () => {
              i = null;
            }),
            St());
      },
      i(f) {
        r || (M(l.$$.fragment, f), M(i), (r = !0));
      },
      o(f) {
        j(l.$$.fragment, f), j(i), (r = !1);
      },
      d(f) {
        f && b(e), Q(l), i && i.d();
      },
    };
  }
  function Yt(t, e, n) {
    let o = !1,
      { project: s } = e,
      { settings: l } = e,
      { article: c } = e,
      u;
    Et(async () => {
      try {
        console.log(l);
        const i = await Bt(s, c.id);
        n(1, (u = atob(i.article.summary))), console.log(u);
      } catch (i) {
        console.log(i);
      }
    });
    const d = () => n(0, (o = !0));
    function r(i) {
      (o = i), n(0, o);
    }
    return (
      (t.$$set = (i) => {
        'project' in i && n(2, (s = i.project)),
          'settings' in i && n(3, (l = i.settings)),
          'article' in i && n(4, (c = i.article));
      }),
      [o, u, s, l, c, d, r]
    );
  }
  class Zt extends X {
    constructor(e) {
      super(), W(this, e, Yt, Xt, R, { project: 2, settings: 3, article: 4 }, Jt);
    }
  }
  let B;
  const te = (t, e, n) => {
      const o = 'getsummer-' + t;
      let s = document.getElementById(o);
      s
        ? s.innerHTML !== '' &&
          (B && typeof B.$destroy == 'function' && B.$destroy(), (s.innerHTML = ''), (B = void 0))
        : ((s = document.createElement('div')), (s.id = o), document.body.appendChild(s)),
        (B = new Zt({ target: s, props: { project: t, settings: e, article: n } }));
    },
    ee = (t, e) => {
      console.log('initApp', t, e),
        Pt(t, e).then((n) => {
          console.log(n), te(t, n.settings, n.article);
        });
    },
    ne = window.GetSummer.key;
  let Y = location.href;
  const oe = new MutationObserver(function () {
      console.log('mutation', location.href),
        location.href !== Y && ((Y = location.href), ee(ne, Y));
    }),
    se = { subtree: !0, childList: !0 };
  oe.observe(document, se);
});
