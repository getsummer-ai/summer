(function (v) {
  typeof define == 'function' && define.amd ? define(v) : v();
})(function () {
  'use strict';
  var fe = Object.defineProperty;
  var de = (v, x, j) =>
    x in v ? fe(v, x, { enumerable: !0, configurable: !0, writable: !0, value: j }) : (v[x] = j);
  var T = (v, x, j) => (de(v, typeof x != 'symbol' ? x + '' : x, j), j);
  function v() {}
  function x(t, e) {
    for (const o in e) t[o] = e[o];
    return t;
  }
  function j(t) {
    return t();
  }
  function et() {
    return Object.create(null);
  }
  function z(t) {
    t.forEach(j);
  }
  function ot(t) {
    return typeof t == 'function';
  }
  function q(t, e) {
    return t != t ? e == e : t !== e || (t && typeof t == 'object') || typeof t == 'function';
  }
  function _t(t) {
    return Object.keys(t).length === 0;
  }
  function nt(t, e, o, n) {
    if (t) {
      const r = rt(t, e, o, n);
      return t[0](r);
    }
  }
  function rt(t, e, o, n) {
    return t[1] && n ? x(o.ctx.slice(), t[1](n(e))) : o.ctx;
  }
  function lt(t, e, o, n) {
    if (t[2] && n) {
      const r = t[2](n(o));
      if (e.dirty === void 0) return r;
      if (typeof r == 'object') {
        const l = [],
          c = Math.max(e.dirty.length, r.length);
        for (let u = 0; u < c; u += 1) l[u] = e.dirty[u] | r[u];
        return l;
      }
      return e.dirty | r;
    }
    return e.dirty;
  }
  function ct(t, e, o, n, r, l) {
    if (r) {
      const c = rt(e, o, n, l);
      t.p(c, r);
    }
  }
  function st(t) {
    if (t.ctx.length > 32) {
      const e = [],
        o = t.ctx.length / 32;
      for (let n = 0; n < o; n++) e[n] = -1;
      return e;
    }
    return -1;
  }
  function k(t, e) {
    t.appendChild(e);
  }
  function it(t, e, o) {
    const n = wt(t);
    if (!n.getElementById(e)) {
      const r = y('style');
      (r.id = e), (r.textContent = o), yt(n, r);
    }
  }
  function wt(t) {
    if (!t) return document;
    const e = t.getRootNode ? t.getRootNode() : t.ownerDocument;
    return e && e.host ? e : t.ownerDocument;
  }
  function yt(t, e) {
    return k(t.head || t, e), e.sheet;
  }
  function w(t, e, o) {
    t.insertBefore(e, o || null);
  }
  function _(t) {
    t.parentNode && t.parentNode.removeChild(t);
  }
  function y(t) {
    return document.createElement(t);
  }
  function xt(t) {
    return document.createElementNS('http://www.w3.org/2000/svg', t);
  }
  function $(t) {
    return document.createTextNode(t);
  }
  function A() {
    return $(' ');
  }
  function jt() {
    return $('');
  }
  function C(t, e, o, n) {
    return t.addEventListener(e, o, n), () => t.removeEventListener(e, o, n);
  }
  function Et(t) {
    return function (e) {
      return e.stopPropagation(), t.call(this, e);
    };
  }
  function Mt(t) {
    return function (e) {
      e.target === this && t.call(this, e);
    };
  }
  function N(t, e, o) {
    o == null ? t.removeAttribute(e) : t.getAttribute(e) !== o && t.setAttribute(e, o);
  }
  function Tt(t) {
    return Array.from(t.childNodes);
  }
  function at(t, e) {
    (e = '' + e), t.data !== e && (t.data = e);
  }
  function L(t, e, o, n) {
    o == null ? t.style.removeProperty(e) : t.style.setProperty(e, o, n ? 'important' : '');
  }
  function $t(t, e, { bubbles: o = !1, cancelable: n = !1 } = {}) {
    return new CustomEvent(t, { detail: e, bubbles: o, cancelable: n });
  }
  class Nt {
    constructor(e = !1) {
      T(this, 'is_svg', !1);
      T(this, 'e');
      T(this, 'n');
      T(this, 't');
      T(this, 'a');
      (this.is_svg = e), (this.e = this.n = null);
    }
    c(e) {
      this.h(e);
    }
    m(e, o, n = null) {
      this.e ||
        (this.is_svg
          ? (this.e = xt(o.nodeName))
          : (this.e = y(o.nodeType === 11 ? 'TEMPLATE' : o.nodeName)),
        (this.t = o.tagName !== 'TEMPLATE' ? o : o.content),
        this.c(e)),
        this.i(n);
    }
    h(e) {
      (this.e.innerHTML = e),
        (this.n = Array.from(
          this.e.nodeName === 'TEMPLATE' ? this.e.content.childNodes : this.e.childNodes,
        ));
    }
    i(e) {
      for (let o = 0; o < this.n.length; o += 1) w(this.t, this.n[o], e);
    }
    p(e) {
      this.d(), this.h(e), this.i(this.a);
    }
    d() {
      this.n.forEach(_);
    }
  }
  let R;
  function D(t) {
    R = t;
  }
  function ut() {
    if (!R) throw new Error('Function called outside component initialization');
    return R;
  }
  function St(t) {
    ut().$$.on_mount.push(t);
  }
  function zt() {
    const t = ut();
    return (e, o, { cancelable: n = !1 } = {}) => {
      const r = t.$$.callbacks[e];
      if (r) {
        const l = $t(e, o, { cancelable: n });
        return (
          r.slice().forEach((c) => {
            c.call(t, l);
          }),
          !l.defaultPrevented
        );
      }
      return !0;
    };
  }
  function At(t, e) {
    const o = t.$$.callbacks[e.type];
    o && o.slice().forEach((n) => n.call(this, e));
  }
  const P = [],
    B = [];
  let O = [];
  const J = [],
    Ct = Promise.resolve();
  let K = !1;
  function Lt() {
    K || ((K = !0), Ct.then(ft));
  }
  function V(t) {
    O.push(t);
  }
  function Pt(t) {
    J.push(t);
  }
  const W = new Set();
  let I = 0;
  function ft() {
    if (I !== 0) return;
    const t = R;
    do {
      try {
        for (; I < P.length; ) {
          const e = P[I];
          I++, D(e), Bt(e.$$);
        }
      } catch (e) {
        throw ((P.length = 0), (I = 0), e);
      }
      for (D(null), P.length = 0, I = 0; B.length; ) B.pop()();
      for (let e = 0; e < O.length; e += 1) {
        const o = O[e];
        W.has(o) || (W.add(o), o());
      }
      O.length = 0;
    } while (P.length);
    for (; J.length; ) J.pop()();
    (K = !1), W.clear(), D(t);
  }
  function Bt(t) {
    if (t.fragment !== null) {
      t.update(), z(t.before_update);
      const e = t.dirty;
      (t.dirty = [-1]), t.fragment && t.fragment.p(t.ctx, e), t.after_update.forEach(V);
    }
  }
  function Ot(t) {
    const e = [],
      o = [];
    O.forEach((n) => (t.indexOf(n) === -1 ? e.push(n) : o.push(n))), o.forEach((n) => n()), (O = e);
  }
  const G = new Set();
  let S;
  function It() {
    S = { r: 0, c: [], p: S };
  }
  function Ht() {
    S.r || z(S.c), (S = S.p);
  }
  function E(t, e) {
    t && t.i && (G.delete(t), t.i(e));
  }
  function H(t, e, o, n) {
    if (t && t.o) {
      if (G.has(t)) return;
      G.add(t),
        S.c.push(() => {
          G.delete(t), n && (o && t.d(1), n());
        }),
        t.o(e);
    } else n && n();
  }
  function Rt(t, e, o) {
    const n = t.$$.props[e];
    n !== void 0 && ((t.$$.bound[n] = o), o(t.$$.ctx[n]));
  }
  function dt(t) {
    t && t.c();
  }
  function X(t, e, o) {
    const { fragment: n, after_update: r } = t.$$;
    n && n.m(e, o),
      V(() => {
        const l = t.$$.on_mount.map(j).filter(ot);
        t.$$.on_destroy ? t.$$.on_destroy.push(...l) : z(l), (t.$$.on_mount = []);
      }),
      r.forEach(V);
  }
  function Q(t, e) {
    const o = t.$$;
    o.fragment !== null &&
      (Ot(o.after_update),
      z(o.on_destroy),
      o.fragment && o.fragment.d(e),
      (o.on_destroy = o.fragment = null),
      (o.ctx = []));
  }
  function Dt(t, e) {
    t.$$.dirty[0] === -1 && (P.push(t), Lt(), t.$$.dirty.fill(0)),
      (t.$$.dirty[(e / 31) | 0] |= 1 << e % 31);
  }
  function Z(t, e, o, n, r, l, c = null, u = [-1]) {
    const f = R;
    D(t);
    const s = (t.$$ = {
      fragment: null,
      ctx: [],
      props: l,
      update: v,
      not_equal: r,
      bound: et(),
      on_mount: [],
      on_destroy: [],
      on_disconnect: [],
      before_update: [],
      after_update: [],
      context: new Map(e.context || (f ? f.$$.context : [])),
      callbacks: et(),
      dirty: u,
      skip_bound: !1,
      root: e.target || f.$$.root,
    });
    c && c(s.root);
    let a = !1;
    if (
      ((s.ctx = o
        ? o(t, e.props || {}, (i, d, ...m) => {
            const h = m.length ? m[0] : d;
            return (
              s.ctx &&
                r(s.ctx[i], (s.ctx[i] = h)) &&
                (!s.skip_bound && s.bound[i] && s.bound[i](h), a && Dt(t, i)),
              d
            );
          })
        : []),
      s.update(),
      (a = !0),
      z(s.before_update),
      (s.fragment = n ? n(s.ctx) : !1),
      e.target)
    ) {
      if (e.hydrate) {
        const i = Tt(e.target);
        s.fragment && s.fragment.l(i), i.forEach(_);
      } else s.fragment && s.fragment.c();
      e.intro && E(t.$$.fragment), X(t, e.target, e.anchor), ft();
    }
    D(f);
  }
  class tt {
    constructor() {
      T(this, '$$');
      T(this, '$$set');
    }
    $destroy() {
      Q(this, 1), (this.$destroy = v);
    }
    $on(e, o) {
      if (!ot(o)) return v;
      const n = this.$$.callbacks[e] || (this.$$.callbacks[e] = []);
      return (
        n.push(o),
        () => {
          const r = n.indexOf(o);
          r !== -1 && n.splice(r, 1);
        }
      );
    }
    $set(e) {
      this.$$set && !_t(e) && ((this.$$.skip_bound = !0), this.$$set(e), (this.$$.skip_bound = !1));
    }
  }
  const Ut = '4';
  typeof window < 'u' && (window.__svelte || (window.__svelte = { v: new Set() })).v.add(Ut);
  const bt = '',
    pt = async (t, e, o = null) =>
      (
        await fetch(t, {
          method: o == null ? 'GET' : 'POST',
          mode: 'cors',
          headers: { 'Content-Type': 'application/json', 'Api-Key': e },
          ...(o == null ? {} : { body: JSON.stringify(o) }),
        })
      ).json(),
    Ft = async (t, e) => pt(`${bt}/api/v1/button/init`, t, { s: e }),
    Gt = async (t, e) => await pt(`${bt}/api/v1/button/summary?id=${encodeURIComponent(e)}`, t);
  function Yt(t) {
    let e, o, n, r, l;
    return {
      c() {
        (e = y('button')), (o = $('count is ')), (n = $(t[0]));
      },
      m(c, u) {
        w(c, e, u), k(e, o), k(e, n), r || ((l = C(e, 'click', t[1])), (r = !0));
      },
      p(c, [u]) {
        u & 1 && at(n, c[0]);
      },
      i: v,
      o: v,
      d(c) {
        c && _(e), (r = !1), l();
      },
    };
  }
  function qt(t, e, o) {
    let n = 0;
    return [
      n,
      () => {
        o(0, (n += 1));
      },
    ];
  }
  class Jt extends tt {
    constructor(e) {
      super(), Z(this, e, qt, Yt, q, {});
    }
  }
  function Kt(t) {
    it(
      t,
      'svelte-w32227',
      'dialog.svelte-w32227.svelte-w32227{max-width:32em;border-radius:0.2em;border:none;padding:0}dialog.svelte-w32227.svelte-w32227::backdrop{background:rgba(0, 0, 0, 0.3)}dialog.svelte-w32227>div.svelte-w32227{padding:1em}dialog[open].svelte-w32227.svelte-w32227{animation:svelte-w32227-zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)}@keyframes svelte-w32227-zoom{from{transform:scale(0.95)}to{transform:scale(1)}}dialog[open].svelte-w32227.svelte-w32227::backdrop{animation:svelte-w32227-fade 0.2s ease-out}@keyframes svelte-w32227-fade{from{opacity:0}to{opacity:1}}button.svelte-w32227.svelte-w32227{display:block}',
    );
  }
  const Vt = (t) => ({}),
    mt = (t) => ({});
  function Wt(t) {
    let e, o, n, r, l, c, u, f, s, a, i, d;
    const m = t[4].header,
      h = nt(m, t, t[3], mt),
      F = t[4].default,
      g = nt(F, t, t[3], null);
    return {
      c() {
        (e = y('dialog')),
          (o = y('div')),
          h && h.c(),
          (n = A()),
          (r = y('hr')),
          (l = A()),
          g && g.c(),
          (c = A()),
          (u = y('hr')),
          (f = A()),
          (s = y('button')),
          (s.textContent = 'close modal'),
          (s.autofocus = !0),
          N(s, 'class', 'svelte-w32227'),
          N(o, 'class', 'svelte-w32227'),
          N(e, 'class', 'svelte-w32227');
      },
      m(p, M) {
        w(p, e, M),
          k(e, o),
          h && h.m(o, null),
          k(o, n),
          k(o, r),
          k(o, l),
          g && g.m(o, null),
          k(o, c),
          k(o, u),
          k(o, f),
          k(o, s),
          t[7](e),
          (a = !0),
          s.focus(),
          i ||
            ((d = [
              C(s, 'click', t[6]),
              C(o, 'click', Et(t[5])),
              C(e, 'close', t[1]),
              C(e, 'click', Mt(t[8])),
            ]),
            (i = !0));
      },
      p(p, [M]) {
        h && h.p && (!a || M & 8) && ct(h, m, p, p[3], a ? lt(m, p[3], M, Vt) : st(p[3]), mt),
          g && g.p && (!a || M & 8) && ct(g, F, p, p[3], a ? lt(F, p[3], M, null) : st(p[3]), null);
      },
      i(p) {
        a || (E(h, p), E(g, p), (a = !0));
      },
      o(p) {
        H(h, p), H(g, p), (a = !1);
      },
      d(p) {
        p && _(e), h && h.d(p), g && g.d(p), t[7](null), (i = !1), z(d);
      },
    };
  }
  function Xt(t, e, o) {
    let { $$slots: n = {}, $$scope: r } = e;
    const l = zt();
    function c() {
      l('close');
    }
    let { showModal: u = !1 } = e,
      f;
    function s(m) {
      At.call(this, t, m);
    }
    const a = () => f.close();
    function i(m) {
      B[m ? 'unshift' : 'push'](() => {
        (f = m), o(0, f);
      });
    }
    const d = () => f.close();
    return (
      (t.$$set = (m) => {
        'showModal' in m && o(2, (u = m.showModal)), '$$scope' in m && o(3, (r = m.$$scope));
      }),
      (t.$$.update = () => {
        t.$$.dirty & 5 && f && u && f.showModal();
      }),
      [f, c, u, r, n, s, a, i, d]
    );
  }
  class Qt extends tt {
    constructor(e) {
      super(), Z(this, e, Xt, Wt, q, { showModal: 2 }, Kt);
    }
  }
  function Zt(t) {
    it(
      t,
      'svelte-1tjx3s1',
      `.getsummer-btn.svelte-1tjx3s1{display:inline-flex;height:3rem;min-height:3rem;flex-shrink:0;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;user-select:none;flex-wrap:wrap;align-items:center;justify-content:center;border-radius:var(--rounded-btn, 0.5rem);border-color:transparent;border-color:oklch(var(--btn-color, var(--b2)) / var(--tw-border-opacity));padding-left:1rem;padding-right:1rem;text-align:center;font-size:0.875rem;line-height:1em;gap:0.5rem;font-weight:600;text-decoration-line:none;transition-duration:200ms;transition-timing-function:cubic-bezier(0, 0, 0.2, 1);border-width:var(--border-btn, 1px);animation:button-pop var(--animation-btn, 0.25s) ease-out;transition-property:color, background-color, border-color, opacity, box-shadow, transform;--tw-text-opacity:1;color:var(--fallback-bc,oklch(var(--bc)/var(--tw-text-opacity)));--tw-shadow:0 1px 2px 0 rgb(0 0 0 / 0.05);--tw-shadow-colored:0 1px 2px 0 var(--tw-shadow-color);box-shadow:var(--tw-ring-offset-shadow, 0 0 #0000), var(--tw-ring-shadow, 0 0 #0000), var(--tw-shadow);outline-color:var(--fallback-bc,oklch(var(--bc)/1));background-color:oklch(var(--btn-color, var(--b2)) / var(--tw-bg-opacity));--tw-bg-opacity:1;--tw-border-opacity:1
}.getsummer-btn.svelte-1tjx3s1:disabled{pointer-events:none
}.svelte-1tjx3s1:where(.getsummer-btn:is(input[type="checkbox"])),.svelte-1tjx3s1:where(.getsummer-btn:is(input[type="radio"])){width:auto;-webkit-appearance:none;-moz-appearance:none;appearance:none
}.getsummer-btn.svelte-1tjx3s1:is(input[type="checkbox"]):after,.getsummer-btn.svelte-1tjx3s1:is(input[type="radio"]):after{--tw-content:attr(aria-label);content:var(--tw-content)
}@media(hover: hover){.getsummer-btn.svelte-1tjx3s1:hover{--tw-border-opacity:1;border-color:var(--fallback-b3,oklch(var(--b3)/var(--tw-border-opacity)));--tw-bg-opacity:1;background-color:var(--fallback-b3,oklch(var(--b3)/var(--tw-bg-opacity)))
  }@supports (color: color-mix(in oklab, black, black)){.getsummer-btn.svelte-1tjx3s1:hover{background-color:color-mix(
            in oklab,
            oklch(var(--btn-color, var(--b2)) / var(--tw-bg-opacity, 1)) 90%,
            black
          );border-color:color-mix(
            in oklab,
            oklch(var(--btn-color, var(--b2)) / var(--tw-border-opacity, 1)) 90%,
            black
          )
    }}@supports not (color: oklch(0 0 0)){.getsummer-btn.svelte-1tjx3s1:hover{background-color:var(--btn-color, var(--fallback-b2));border-color:var(--btn-color, var(--fallback-b2))
    }}.getsummer-btn.svelte-1tjx3s1:hover{--tw-border-opacity:1;border-color:var(--fallback-b3,oklch(var(--b3)/var(--tw-border-opacity)));--tw-bg-opacity:1;background-color:var(--fallback-b3,oklch(var(--b3)/var(--tw-bg-opacity)))
  }@supports (color: color-mix(in oklab, black, black)){.getsummer-btn.svelte-1tjx3s1:hover{background-color:color-mix(
            in oklab,
            oklch(var(--btn-color, var(--b2)) / var(--tw-bg-opacity, 1)) 90%,
            black
          );border-color:color-mix(
            in oklab,
            oklch(var(--btn-color, var(--b2)) / var(--tw-border-opacity, 1)) 90%,
            black
          )
    }}@supports not (color: oklch(0 0 0)){.getsummer-btn.svelte-1tjx3s1:hover{background-color:var(--btn-color, var(--fallback-b2));border-color:var(--btn-color, var(--fallback-b2))
    }}.getsummer-btn.svelte-1tjx3s1:hover{--tw-border-opacity:1;border-color:var(--fallback-b3,oklch(var(--b3)/var(--tw-border-opacity)));--tw-bg-opacity:1;background-color:var(--fallback-b3,oklch(var(--b3)/var(--tw-bg-opacity)))
  }@supports (color: color-mix(in oklab, black, black)){.getsummer-btn.svelte-1tjx3s1:hover{background-color:color-mix(
            in oklab,
            oklch(var(--btn-color, var(--b2)) / var(--tw-bg-opacity, 1)) 90%,
            black
          );border-color:color-mix(
            in oklab,
            oklch(var(--btn-color, var(--b2)) / var(--tw-border-opacity, 1)) 90%,
            black
          )
    }}@supports not (color: oklch(0 0 0)){.getsummer-btn.svelte-1tjx3s1:hover{background-color:var(--btn-color, var(--fallback-b2));border-color:var(--btn-color, var(--fallback-b2))
    }}@supports (color: color-mix(in oklab, black, black)){}@supports (color: color-mix(in oklab, black, black)){}.getsummer-btn.svelte-1tjx3s1:disabled:hover{--tw-border-opacity:0;background-color:var(--fallback-n,oklch(var(--n)/var(--tw-bg-opacity)));--tw-bg-opacity:0.2;color:var(--fallback-bc,oklch(var(--bc)/var(--tw-text-opacity)));--tw-text-opacity:0.2
  }@supports (color: color-mix(in oklab, black, black)){.getsummer-btn.svelte-1tjx3s1:is(input[type="checkbox"]:checked):hover,.getsummer-btn.svelte-1tjx3s1:is(input[type="radio"]:checked):hover{background-color:color-mix(in oklab, var(--fallback-p,oklch(var(--p)/1)) 90%, black);border-color:color-mix(in oklab, var(--fallback-p,oklch(var(--p)/1)) 90%, black)
    }}}.getsummer-btn.svelte-1tjx3s1:active:hover,.getsummer-btn.svelte-1tjx3s1:active:focus{animation:button-pop 0s ease-out;transform:scale(var(--btn-focus-scale, 0.97))
}@supports not (color: oklch(0 0 0)){.getsummer-btn.svelte-1tjx3s1{background-color:var(--btn-color, var(--fallback-b2));border-color:var(--btn-color, var(--fallback-b2));--btn-color:var(--fallback-a)
  }}@supports (color: color-mix(in oklab, black, black)){}.getsummer-btn.svelte-1tjx3s1:focus-visible{outline-style:solid;outline-width:2px;outline-offset:2px
}@supports (color: oklch(0 0 0)){.getsummer-btn.svelte-1tjx3s1{--btn-color:var(--a)
  }}.getsummer-btn.svelte-1tjx3s1{--tw-text-opacity:1;color:var(--fallback-ac,oklch(var(--ac)/var(--tw-text-opacity)));outline-color:var(--fallback-a,oklch(var(--a)/1))
}.getsummer-btn.svelte-1tjx3s1:disabled{--tw-border-opacity:0;background-color:var(--fallback-n,oklch(var(--n)/var(--tw-bg-opacity)));--tw-bg-opacity:0.2;color:var(--fallback-bc,oklch(var(--bc)/var(--tw-text-opacity)));--tw-text-opacity:0.2
}.getsummer-btn.svelte-1tjx3s1:is(input[type="checkbox"]:checked),.getsummer-btn.svelte-1tjx3s1:is(input[type="radio"]:checked){--tw-border-opacity:1;border-color:var(--fallback-p,oklch(var(--p)/var(--tw-border-opacity)));--tw-bg-opacity:1;background-color:var(--fallback-p,oklch(var(--p)/var(--tw-bg-opacity)));--tw-text-opacity:1;color:var(--fallback-pc,oklch(var(--pc)/var(--tw-text-opacity)))
}.getsummer-btn.svelte-1tjx3s1:is(input[type="checkbox"]:checked):focus-visible,.getsummer-btn.svelte-1tjx3s1:is(input[type="radio"]:checked):focus-visible{outline-color:var(--fallback-p,oklch(var(--p)/1))
}.getsummer-btn.svelte-1tjx3s1{height:2rem;min-height:2rem;padding-left:0.75rem;padding-right:0.75rem;font-size:0.875rem
}.getsummer-btn.svelte-1tjx3s1{position:absolute;transition-property:opacity;transition-duration:500ms;transition-timing-function:cubic-bezier(0.4, 0, 0.2, 1)
}@keyframes svelte-1tjx3s1-bounce{0%,100%{transform:translateY(-25%);animation-timing-function:cubic-bezier(0.8,0,1,1)
  }50%{transform:none;animation-timing-function:cubic-bezier(0,0,0.2,1)
  }}.getsummer-btn.animate.svelte-1tjx3s1{animation:svelte-1tjx3s1-bounce 1s infinite;animation-iteration-count:2.5
}`,
    );
  }
  function te(t) {
    let e;
    return {
      c() {
        e = $('Summorize');
      },
      m(o, n) {
        w(o, e, n);
      },
      d(o) {
        o && _(e);
      },
    };
  }
  function ee(t) {
    let e, o;
    return {
      c() {
        (e = y('span')),
          (o = $(`
    Summorizing`)),
          N(e, 'class', 'loading loading-spinner loading-xs svelte-1tjx3s1');
      },
      m(n, r) {
        w(n, e, r), w(n, o, r);
      },
      d(n) {
        n && (_(e), _(o));
      },
    };
  }
  function ht(t) {
    let e, o, n;
    function r(c) {
      t[14](c);
    }
    let l = { $$slots: { header: [ne], default: [oe] }, $$scope: { ctx: t } };
    return (
      t[1] !== void 0 && (l.showModal = t[1]),
      (e = new Qt({ props: l })),
      B.push(() => Rt(e, 'showModal', r)),
      e.$on('close', t[9]),
      {
        c() {
          dt(e.$$.fragment);
        },
        m(c, u) {
          X(e, c, u), (n = !0);
        },
        p(c, u) {
          const f = {};
          u & 65557 && (f.$$scope = { dirty: u, ctx: c }),
            !o && u & 2 && ((o = !0), (f.showModal = c[1]), Pt(() => (o = !1))),
            e.$set(f);
        },
        i(c) {
          n || (E(e.$$.fragment, c), (n = !0));
        },
        o(c) {
          H(e.$$.fragment, c), (n = !1);
        },
        d(c) {
          Q(e, c);
        },
      }
    );
  }
  function oe(t) {
    let e, o, n, r;
    return (
      (n = new Jt({})),
      {
        c() {
          (e = new Nt(!1)), (o = A()), dt(n.$$.fragment), (e.a = o);
        },
        m(l, c) {
          e.m(t[2], l, c), w(l, o, c), X(n, l, c), (r = !0);
        },
        p(l, c) {
          (!r || c & 4) && e.p(l[2]);
        },
        i(l) {
          r || (E(n.$$.fragment, l), (r = !0));
        },
        o(l) {
          H(n.$$.fragment, l), (r = !1);
        },
        d(l) {
          l && (e.d(), _(o)), Q(n, l);
        },
      }
    );
  }
  function ne(t) {
    let e,
      o = t[0].title + '',
      n;
    return {
      c() {
        (e = y('h2')), (n = $(o)), N(e, 'slot', 'header'), N(e, 'class', 'svelte-1tjx3s1');
      },
      m(r, l) {
        w(r, e, l), k(e, n), t[13](e);
      },
      p(r, l) {
        l & 1 && o !== (o = r[0].title + '') && at(n, o);
      },
      d(r) {
        r && _(e), t[13](null);
      },
    };
  }
  function re(t) {
    let e, o, n, r, l, c;
    function u(i, d) {
      return i[5] ? ee : te;
    }
    let f = u(t),
      s = f(t),
      a = t[6] && ht(t);
    return {
      c() {
        (e = y('button')),
          s.c(),
          (o = A()),
          a && a.c(),
          (n = jt()),
          N(e, 'class', 'getsummer-btn animate svelte-1tjx3s1'),
          L(e, 'left', t[7].left + 'px'),
          L(e, 'top', t[7].top + 'px'),
          L(e, 'opacity', t[7].opacity);
      },
      m(i, d) {
        w(i, e, d),
          s.m(e, null),
          t[12](e),
          w(i, o, d),
          a && a.m(i, d),
          w(i, n, d),
          (r = !0),
          l || ((c = C(e, 'click', t[8])), (l = !0));
      },
      p(i, [d]) {
        f !== (f = u(i)) && (s.d(1), (s = f(i)), s && (s.c(), s.m(e, null))),
          (!r || d & 128) && L(e, 'left', i[7].left + 'px'),
          (!r || d & 128) && L(e, 'top', i[7].top + 'px'),
          (!r || d & 128) && L(e, 'opacity', i[7].opacity),
          i[6]
            ? a
              ? (a.p(i, d), d & 64 && E(a, 1))
              : ((a = ht(i)), a.c(), E(a, 1), a.m(n.parentNode, n))
            : a &&
              (It(),
              H(a, 1, 1, () => {
                a = null;
              }),
              Ht());
      },
      i(i) {
        r || (E(a), (r = !0));
      },
      o(i) {
        H(a), (r = !1);
      },
      d(i) {
        i && (_(e), _(o), _(n)), s.d(), t[12](null), a && a.d(i), (l = !1), c();
      },
    };
  }
  function le() {
    return { left: -200, top: 9999, opacity: 0 };
  }
  function ce(t, e, o) {
    let n = !1,
      { project: r } = e,
      { settings: l } = e,
      { article: c } = e,
      u,
      f,
      s,
      a = !1,
      i = !1,
      d = le();
    St(async () => {
      document.querySelectorAll('h1, h2, h3').forEach((b) => {
        if (s === b || i || !b.innerHTML.includes(c.title)) return;
        const kt = b.getBoundingClientRect();
        o(
          7,
          (d = {
            left: kt.left + window.scrollX - (f.offsetWidth + 10),
            top: kt.top + window.scrollY,
            opacity: 1,
          }),
        ),
          o(6, (i = !0));
      });
    });
    const m = (b = 100) => {
        setTimeout(() => {
          console.log(l, u), o(1, (n = !0)), o(7, (d.opacity = 0), d);
        }, b);
      },
      h = async () => {
        if (u) return m();
        o(5, (a = !0));
        try {
          const b = await Gt(r, c.id);
          o(2, (u = atob(b.article.summary))), m(1e3);
        } catch (b) {
          console.log(b), o(5, (a = !1));
        }
      },
      F = () => {
        o(5, (a = !1)), o(1, (n = !1)), setTimeout(() => o(7, (d.opacity = 1), d), 500);
      };
    function g(b) {
      B[b ? 'unshift' : 'push'](() => {
        (f = b), o(3, f);
      });
    }
    function p(b) {
      B[b ? 'unshift' : 'push'](() => {
        (s = b), o(4, s);
      });
    }
    function M(b) {
      (n = b), o(1, n);
    }
    return (
      (t.$$set = (b) => {
        'project' in b && o(10, (r = b.project)),
          'settings' in b && o(11, (l = b.settings)),
          'article' in b && o(0, (c = b.article));
      }),
      [c, n, u, f, s, a, i, d, h, F, r, l, g, p, M]
    );
  }
  class se extends tt {
    constructor(e) {
      super(), Z(this, e, ce, re, q, { project: 10, settings: 11, article: 0 }, Zt);
    }
  }
  let U;
  const ie = (t, e, o) => {
      const n = 'getsummer-' + t;
      let r = document.getElementById(n);
      r
        ? r.innerHTML !== '' &&
          (U && typeof U.$destroy == 'function' && U.$destroy(), (r.innerHTML = ''), (U = void 0))
        : ((r = document.createElement('div')), (r.id = n), document.body.appendChild(r)),
        (U = new se({ target: r, props: { project: t, settings: e, article: o } }));
    },
    vt = (t, e) => {
      Ft(t, e).then((o) => {
        ie(t, o.settings, o.article);
      });
    },
    gt = window.GetSummer.key;
  let Y = location.href;
  vt(gt, Y);
  const ae = new MutationObserver(function () {
      location.href !== Y &&
        (console.log('mutation init app', location.href), (Y = location.href), vt(gt, Y));
    }),
    ue = { subtree: !0, childList: !0 };
  ae.observe(document, ue);
});
