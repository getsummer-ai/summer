(function (b) {
  typeof define == 'function' && define.amd ? define(b) : b();
})(function () {
  'use strict';
  var Xt = Object.defineProperty;
  var en = (b, P, C) =>
    P in b ? Xt(b, P, { enumerable: !0, configurable: !0, writable: !0, value: C }) : (b[P] = C);
  var B = (b, P, C) => (en(b, typeof P != 'symbol' ? P + '' : P, C), C);
  function b() {}
  function P(e, t) {
    for (const n in t) e[n] = t[n];
    return e;
  }
  function C(e) {
    return e();
  }
  function Ee() {
    return Object.create(null);
  }
  function O(e) {
    e.forEach(C);
  }
  function Ae(e) {
    return typeof e == 'function';
  }
  function K(e, t) {
    return e != e ? t == t : e !== t || (e && typeof e == 'object') || typeof e == 'function';
  }
  let ee;
  function Se(e, t) {
    return e === t ? !0 : (ee || (ee = document.createElement('a')), (ee.href = t), e === ee.href);
  }
  function nt(e) {
    return Object.keys(e).length === 0;
  }
  function Me(e, t, n, o) {
    if (e) {
      const s = Ie(e, t, n, o);
      return e[0](s);
    }
  }
  function Ie(e, t, n, o) {
    return e[1] && o ? P(n.ctx.slice(), e[1](o(t))) : n.ctx;
  }
  function Te(e, t, n, o) {
    if (e[2] && o) {
      const s = e[2](o(n));
      if (t.dirty === void 0) return s;
      if (typeof s == 'object') {
        const c = [],
          r = Math.max(t.dirty.length, s.length);
        for (let i = 0; i < r; i += 1) c[i] = t.dirty[i] | s[i];
        return c;
      }
      return t.dirty | s;
    }
    return t.dirty;
  }
  function $e(e, t, n, o, s, c) {
    if (s) {
      const r = Ie(t, n, o, c);
      e.p(r, s);
    }
  }
  function Ne(e) {
    if (e.ctx.length > 32) {
      const t = [],
        n = e.ctx.length / 32;
      for (let o = 0; o < n; o++) t[o] = -1;
      return t;
    }
    return -1;
  }
  function y(e, t) {
    e.appendChild(t);
  }
  function te(e, t, n) {
    const o = ot(e);
    if (!o.getElementById(t)) {
      const s = w('style');
      (s.id = t), (s.textContent = n), st(o, s);
    }
  }
  function ot(e) {
    if (!e) return document;
    const t = e.getRootNode ? e.getRootNode() : e.ownerDocument;
    return t && t.host ? t : e.ownerDocument;
  }
  function st(e, t) {
    return y(e.head || e, t), t.sheet;
  }
  function E(e, t, n) {
    e.insertBefore(t, n || null);
  }
  function z(e) {
    e.parentNode && e.parentNode.removeChild(e);
  }
  function rt(e, t) {
    for (let n = 0; n < e.length; n += 1) e[n] && e[n].d(t);
  }
  function w(e) {
    return document.createElement(e);
  }
  function it(e) {
    return document.createElementNS('http://www.w3.org/2000/svg', e);
  }
  function Y(e) {
    return document.createTextNode(e);
  }
  function R() {
    return Y(' ');
  }
  function ne() {
    return Y('');
  }
  function L(e, t, n, o) {
    return e.addEventListener(t, n, o), () => e.removeEventListener(t, n, o);
  }
  function lt(e) {
    return function (t) {
      return t.stopPropagation(), e.call(this, t);
    };
  }
  function ct(e) {
    return function (t) {
      t.target === this && e.call(this, t);
    };
  }
  function v(e, t, n) {
    n == null ? e.removeAttribute(t) : e.getAttribute(t) !== n && e.setAttribute(t, n);
  }
  function ut(e) {
    return Array.from(e.childNodes);
  }
  function at(e, t) {
    (t = '' + t), e.data !== t && (e.data = t);
  }
  function Pe(e, t) {
    e.value = t ?? '';
  }
  function Ce(e, t, n, o) {
    n == null ? e.style.removeProperty(t) : e.style.setProperty(t, n, o ? 'important' : '');
  }
  function ft(e, t, { bubbles: n = !1, cancelable: o = !1 } = {}) {
    return new CustomEvent(e, { detail: t, bubbles: n, cancelable: o });
  }
  class pt {
    constructor(t = !1) {
      B(this, 'is_svg', !1);
      B(this, 'e');
      B(this, 'n');
      B(this, 't');
      B(this, 'a');
      (this.is_svg = t), (this.e = this.n = null);
    }
    c(t) {
      this.h(t);
    }
    m(t, n, o = null) {
      this.e ||
        (this.is_svg
          ? (this.e = it(n.nodeName))
          : (this.e = w(n.nodeType === 11 ? 'TEMPLATE' : n.nodeName)),
        (this.t = n.tagName !== 'TEMPLATE' ? n : n.content),
        this.c(t)),
        this.i(o);
    }
    h(t) {
      (this.e.innerHTML = t),
        (this.n = Array.from(
          this.e.nodeName === 'TEMPLATE' ? this.e.content.childNodes : this.e.childNodes,
        ));
    }
    i(t) {
      for (let n = 0; n < this.n.length; n += 1) E(this.t, this.n[n], t);
    }
    p(t) {
      this.d(), this.h(t), this.i(this.a);
    }
    d() {
      this.n.forEach(z);
    }
  }
  let J;
  function V(e) {
    J = e;
  }
  function Le() {
    if (!J) throw new Error('Function called outside component initialization');
    return J;
  }
  function dt(e) {
    Le().$$.on_mount.push(e);
  }
  function gt() {
    const e = Le();
    return (t, n, { cancelable: o = !1 } = {}) => {
      const s = e.$$.callbacks[t];
      if (s) {
        const c = ft(t, n, { cancelable: o });
        return (
          s.slice().forEach((r) => {
            r.call(e, c);
          }),
          !c.defaultPrevented
        );
      }
      return !0;
    };
  }
  function mt(e, t) {
    const n = e.$$.callbacks[t.type];
    n && n.slice().forEach((o) => o.call(this, t));
  }
  const F = [],
    G = [];
  let q = [];
  const he = [],
    ht = Promise.resolve();
  let ve = !1;
  function vt() {
    ve || ((ve = !0), ht.then(Oe));
  }
  function be(e) {
    q.push(e);
  }
  function Be(e) {
    he.push(e);
  }
  const _e = new Set();
  let Q = 0;
  function Oe() {
    if (Q !== 0) return;
    const e = J;
    do {
      try {
        for (; Q < F.length; ) {
          const t = F[Q];
          Q++, V(t), bt(t.$$);
        }
      } catch (t) {
        throw ((F.length = 0), (Q = 0), t);
      }
      for (V(null), F.length = 0, Q = 0; G.length; ) G.pop()();
      for (let t = 0; t < q.length; t += 1) {
        const n = q[t];
        _e.has(n) || (_e.add(n), n());
      }
      q.length = 0;
    } while (F.length);
    for (; he.length; ) he.pop()();
    (ve = !1), _e.clear(), V(e);
  }
  function bt(e) {
    if (e.fragment !== null) {
      e.update(), O(e.before_update);
      const t = e.dirty;
      (e.dirty = [-1]), e.fragment && e.fragment.p(e.ctx, t), e.after_update.forEach(be);
    }
  }
  function _t(e) {
    const t = [],
      n = [];
    q.forEach((o) => (e.indexOf(o) === -1 ? t.push(o) : n.push(o))), n.forEach((o) => o()), (q = t);
  }
  const oe = new Set();
  let j;
  function se() {
    j = { r: 0, c: [], p: j };
  }
  function re() {
    j.r || O(j.c), (j = j.p);
  }
  function x(e, t) {
    e && e.i && (oe.delete(e), e.i(t));
  }
  function S(e, t, n, o) {
    if (e && e.o) {
      if (oe.has(e)) return;
      oe.add(e),
        j.c.push(() => {
          oe.delete(e), o && (n && e.d(1), o());
        }),
        e.o(t);
    } else o && o();
  }
  function Re(e) {
    return (e == null ? void 0 : e.length) !== void 0 ? e : Array.from(e);
  }
  function je(e, t, n) {
    const o = e.$$.props[t];
    o !== void 0 && ((e.$$.bound[o] = n), n(e.$$.ctx[o]));
  }
  function xe(e) {
    e && e.c();
  }
  function ie(e, t, n) {
    const { fragment: o, after_update: s } = e.$$;
    o && o.m(t, n),
      be(() => {
        const c = e.$$.on_mount.map(C).filter(Ae);
        e.$$.on_destroy ? e.$$.on_destroy.push(...c) : O(c), (e.$$.on_mount = []);
      }),
      s.forEach(be);
  }
  function le(e, t) {
    const n = e.$$;
    n.fragment !== null &&
      (_t(n.after_update),
      O(n.on_destroy),
      n.fragment && n.fragment.d(t),
      (n.on_destroy = n.fragment = null),
      (n.ctx = []));
  }
  function xt(e, t) {
    e.$$.dirty[0] === -1 && (F.push(e), vt(), e.$$.dirty.fill(0)),
      (e.$$.dirty[(t / 31) | 0] |= 1 << t % 31);
  }
  function ce(e, t, n, o, s, c, r = null, i = [-1]) {
    const l = J;
    V(e);
    const u = (e.$$ = {
      fragment: null,
      ctx: [],
      props: c,
      update: b,
      not_equal: s,
      bound: Ee(),
      on_mount: [],
      on_destroy: [],
      on_disconnect: [],
      before_update: [],
      after_update: [],
      context: new Map(t.context || (l ? l.$$.context : [])),
      callbacks: Ee(),
      dirty: i,
      skip_bound: !1,
      root: t.target || l.$$.root,
    });
    r && r(u.root);
    let p = !1;
    if (
      ((u.ctx = n
        ? n(e, t.props || {}, (a, f, ...h) => {
            const m = h.length ? h[0] : f;
            return (
              u.ctx &&
                s(u.ctx[a], (u.ctx[a] = m)) &&
                (!u.skip_bound && u.bound[a] && u.bound[a](m), p && xt(e, a)),
              f
            );
          })
        : []),
      u.update(),
      (p = !0),
      O(u.before_update),
      (u.fragment = o ? o(u.ctx) : !1),
      t.target)
    ) {
      if (t.hydrate) {
        const a = ut(t.target);
        u.fragment && u.fragment.l(a), a.forEach(z);
      } else u.fragment && u.fragment.c();
      t.intro && x(e.$$.fragment), ie(e, t.target, t.anchor), Oe();
    }
    V(l);
  }
  class ue {
    constructor() {
      B(this, '$$');
      B(this, '$$set');
    }
    $destroy() {
      le(this, 1), (this.$destroy = b);
    }
    $on(t, n) {
      if (!Ae(n)) return b;
      const o = this.$$.callbacks[t] || (this.$$.callbacks[t] = []);
      return (
        o.push(n),
        () => {
          const s = o.indexOf(n);
          s !== -1 && o.splice(s, 1);
        }
      );
    }
    $set(t) {
      this.$$set && !nt(t) && ((this.$$.skip_bound = !0), this.$$set(t), (this.$$.skip_bound = !1));
    }
  }
  const yt = '4';
  typeof window < 'u' && (window.__svelte || (window.__svelte = { v: new Set() })).v.add(yt);
  const Z = [];
  function De(e, t = b) {
    let n;
    const o = new Set();
    function s(i) {
      if (K(e, i) && ((e = i), n)) {
        const l = !Z.length;
        for (const u of o) u[1](), Z.push(u, e);
        if (l) {
          for (let u = 0; u < Z.length; u += 2) Z[u][0](Z[u + 1]);
          Z.length = 0;
        }
      }
    }
    function c(i) {
      s(i(e));
    }
    function r(i, l = b) {
      const u = [i, l];
      return (
        o.add(u),
        o.size === 1 && (n = t(s, c) || b),
        i(e),
        () => {
          o.delete(u), o.size === 0 && n && (n(), (n = null));
        }
      );
    }
    return { set: s, update: c, subscribe: r };
  }
  const ae = 'https://app.getsummer.ai',
    fe = async (e, t, n = null) => {
      const o = await fetch(e, {
        method: n == null ? 'GET' : 'POST',
        mode: 'cors',
        headers: { 'Content-Type': 'application/json', 'Api-Key': t },
        ...(n == null ? {} : { body: JSON.stringify(n) }),
      });
      let s = await o.text();
      if (s)
        try {
          return (s = JSON.parse(s)), { status: o.status, body: s };
        } catch (c) {
          console.log(c);
        }
      return { status: o.status, body: null };
    },
    wt = async (e, t) => fe(`${ae}/api/v1/button/init`, e, { s: t }),
    zt = (e, t) => {
      const n = new EventSource(`/api/v1/pages/${t}/summary?key=${e}`),
        o = De(''),
        s = De(!1);
      return (
        n.addEventListener('message', (c) => {
          o.set(c.data);
        }),
        n.addEventListener('error', (c) => {
          c.eventPhase === EventSource.CLOSED && (n.close(), s.set(!0));
        }),
        { result: o, isCompleted: s }
      );
    },
    kt = (e, t) => fe(`${ae}/api/v1/pages/${t}/products`, e),
    Et = (e, t, n) => fe(`${ae}/api/v1/pages/${t}/products/${n}/click`, e, {}),
    At = (e, t, n) => fe(`${ae}/api/v1/pages/${t}/subscribe`, e, { email: n });
  let pe;
  const ye = (e) => {
    if (!e && pe) return pe;
    if (!e) throw new Error('projectId is required');
    return (
      (pe = {
        clickService: Et.bind(null, e),
        getServices: kt.bind(null, e),
        getSummary: zt.bind(null, e),
        subscribe: At.bind(null, e),
      }),
      pe
    );
  };
  function St(e) {
    te(
      e,
      'svelte-132zvnp',
      'dialog.svelte-132zvnp.svelte-132zvnp{width:100%;max-width:560px;border:none;border-radius:16px;background:#FFF;font-size:16px;line-height:20px;font-style:normal;font-weight:400}dialog.svelte-132zvnp .gtsm-dialog.svelte-132zvnp{position:relative;padding:60px 0 0}dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp{position:relative;max-height:70vh;overflow-y:auto;padding:0 30px 30px 30px;transition:max-height 0.5s, height 0.5s}@media(max-height: 40px){dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp{max-height:20vh}}@media(max-height: 500px){dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp{max-height:40vh}}@media(max-height: 650px){dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp{max-height:50vh}}dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp ul{margin:0;padding:0 0 0 15px;list-style-type:disc;list-style-position:outside}dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp li{margin:0 0 8px 0;padding:0}dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp p{margin:0 0 8px 0;padding:0}dialog.svelte-132zvnp .gtsm-body.svelte-132zvnp p:first-child{margin-bottom:12px}dialog.svelte-132zvnp .gtsm-footer.svelte-132zvnp{position:relative;z-index:10;min-height:3rem;box-shadow:0px -25px 14px -11px #fff;-webkit-box-shadow:0px -25px 14px -11px #fff;-moz-box-shadow:0px -25px 14px -11px #fff;border-top:1px solid #EFEFEF}dialog.svelte-132zvnp.svelte-132zvnp::backdrop{background:rgba(0, 0, 0, 0.3)}dialog[open].svelte-132zvnp.svelte-132zvnp{animation:svelte-132zvnp-zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)}@keyframes svelte-132zvnp-zoom{from{transform:scale(0.95)}to{transform:scale(1)}}dialog[open].svelte-132zvnp.svelte-132zvnp::backdrop{animation:svelte-132zvnp-fade 0.2s ease-out}@keyframes svelte-132zvnp-fade{from{opacity:0}to{opacity:1}}.gtsm-close.svelte-132zvnp.svelte-132zvnp{position:absolute;top:12px;right:12px;display:inline-block;width:24px;height:24px;text-align:center;cursor:pointer;background:rgba(0, 0, 0, 0.05);border-radius:50%;transition:background-color 0.1s}.gtsm-close.svelte-132zvnp.svelte-132zvnp:hover{background:#e1e1e1}.gtsm-close__x.svelte-132zvnp.svelte-132zvnp{position:relative;top:-1px;left:-0.5px;display:inline-block;width:10px;height:10px}.gtsm-close__x.svelte-132zvnp.svelte-132zvnp::before,.gtsm-close__x.svelte-132zvnp.svelte-132zvnp::after{position:absolute;width:1px;height:10px;content:" ";background-color:black}.gtsm-close__x.svelte-132zvnp.svelte-132zvnp::before{transform:rotate(-45deg)}.gtsm-close__x.svelte-132zvnp.svelte-132zvnp::after{transform:rotate(45deg)}.gtsm-close.svelte-132zvnp:active .gtsm-close__x.svelte-132zvnp{top:-1px;left:-0.5px}.gtsm-close.svelte-132zvnp.svelte-132zvnp:active{top:11px;right:11px;width:26px;height:26px;background:#e1e1e1}',
    );
  }
  const Mt = (e) => ({}),
    He = (e) => ({});
  function It(e) {
    let t, n, o, s, c, r, i, l, u, p;
    const a = e[4].default,
      f = Me(a, e, e[3], null),
      h = e[4].footer,
      m = Me(h, e, e[3], He);
    return {
      c() {
        (t = w('dialog')),
          (n = w('div')),
          (o = w('button')),
          (o.innerHTML = '<span class="gtsm-close__x svelte-132zvnp"></span>'),
          (s = R()),
          (c = w('div')),
          f && f.c(),
          (r = R()),
          (i = w('div')),
          m && m.c(),
          v(o, 'class', 'gtsm-close svelte-132zvnp'),
          v(o, 'tabindex', '0'),
          v(c, 'class', 'gtsm-body svelte-132zvnp'),
          v(i, 'class', 'gtsm-footer svelte-132zvnp'),
          v(n, 'class', 'gtsm-dialog svelte-132zvnp'),
          v(t, 'class', 'svelte-132zvnp');
      },
      m(g, N) {
        E(g, t, N),
          y(t, n),
          y(n, o),
          y(n, s),
          y(n, c),
          f && f.m(c, null),
          y(n, r),
          y(n, i),
          m && m.m(i, null),
          e[7](t),
          (l = !0),
          u ||
            ((p = [
              L(o, 'click', e[6]),
              L(n, 'click', lt(e[5])),
              L(t, 'close', e[1]),
              L(t, 'click', ct(e[8])),
            ]),
            (u = !0));
      },
      p(g, [N]) {
        f && f.p && (!l || N & 8) && $e(f, a, g, g[3], l ? Te(a, g[3], N, null) : Ne(g[3]), null),
          m && m.p && (!l || N & 8) && $e(m, h, g, g[3], l ? Te(h, g[3], N, Mt) : Ne(g[3]), He);
      },
      i(g) {
        l || (x(f, g), x(m, g), (l = !0));
      },
      o(g) {
        S(f, g), S(m, g), (l = !1);
      },
      d(g) {
        g && z(t), f && f.d(g), m && m.d(g), e[7](null), (u = !1), O(p);
      },
    };
  }
  function Tt(e, t, n) {
    let { $$slots: o = {}, $$scope: s } = t;
    const c = gt();
    function r() {
      c('close');
    }
    let { showModal: i = !1 } = t,
      l;
    function u(h) {
      mt.call(this, e, h);
    }
    const p = () => l.close();
    function a(h) {
      G[h ? 'unshift' : 'push'](() => {
        (l = h), n(0, l);
      });
    }
    const f = () => l.close();
    return (
      (e.$$set = (h) => {
        'showModal' in h && n(2, (i = h.showModal)), '$$scope' in h && n(3, (s = h.$$scope));
      }),
      (e.$$.update = () => {
        e.$$.dirty & 5 && l && i && l.showModal();
      }),
      [l, r, i, s, o, u, p, a, f]
    );
  }
  class $t extends ue {
    constructor(t) {
      super(), ce(this, t, Tt, It, K, { showModal: 2 }, St);
    }
  }
  function Nt(e) {
    te(
      e,
      'svelte-12rmtvo',
      'a.svelte-12rmtvo.svelte-12rmtvo{font-size:16px;border-radius:12px;border:1px solid #e6e6e9;background:#fff;box-shadow:0 2px 4px 0 #e6e6e9;padding:9px 12px;display:flex;justify-content:space-between;align-items:center;text-decoration:none;color:black;margin-top:20px;animation:svelte-12rmtvo-zoom 1s cubic-bezier(0.34, 1.56, 0.64, 1)}a.svelte-12rmtvo img.svelte-12rmtvo{width:auto;max-height:45px;border-radius:4px}a.svelte-12rmtvo.svelte-12rmtvo:not(:first-of-type){margin-top:10px}a.svelte-12rmtvo.svelte-12rmtvo:hover{background-color:#f8f8f8}@keyframes svelte-12rmtvo-zoom{from{opacity:0.2;transform:scale(0.95)}to{opacity:1;transform:scale(1)}}',
    );
  }
  function Pt(e) {
    let t,
      n,
      o,
      s,
      c,
      r,
      i = e[0].name + '',
      l,
      u,
      p,
      a,
      f,
      h;
    return {
      c() {
        (t = w('a')),
          (n = w('div')),
          (o = w('img')),
          (c = R()),
          (r = w('span')),
          (l = Y(i)),
          (u = R()),
          (p = w('div')),
          (p.innerHTML =
            '<svg width="18" height="11" viewBox="0 0 18 11" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M17.208 5.32L12.232 10.296H10.456L14.792 5.944H-0.00799996V4.696H14.824L10.472 0.344H12.248L17.208 5.32Z" fill="black"></path></svg>'),
          v(o, 'alt', 'preview'),
          Se(o.src, (s = 'data:image/webp;base64,' + (e[0].icon ? e[0].icon : Fe))) ||
            v(o, 'src', s),
          v(o, 'class', 'svelte-12rmtvo'),
          v(r, 'class', 'ml-5'),
          v(n, 'class', 'flex justify-between items-center'),
          v(t, 'target', '_blank'),
          v(t, 'href', (a = e[0].link)),
          v(t, 'class', 'svelte-12rmtvo');
      },
      m(m, g) {
        E(m, t, g),
          y(t, n),
          y(n, o),
          y(n, c),
          y(n, r),
          y(r, l),
          y(t, u),
          y(t, p),
          f || ((h = L(t, 'click', e[1])), (f = !0));
      },
      p(m, [g]) {
        g & 1 &&
          !Se(o.src, (s = 'data:image/webp;base64,' + (m[0].icon ? m[0].icon : Fe))) &&
          v(o, 'src', s),
          g & 1 && i !== (i = m[0].name + '') && at(l, i),
          g & 1 && a !== (a = m[0].link) && v(t, 'href', a);
      },
      i: b,
      o: b,
      d(m) {
        m && z(t), (f = !1), h();
      },
    };
  }
  const Fe =
    'UklGRu4BAABXRUJQVlA4IOIBAABQDACdASo+AC0APoU4l0elI6IhMrbeYKAQiWoAnTKvOre08kyAEAntgH4zAZy9vkOgh4JcOf6+UHtoYnnQI0ofxVdaPK953IrCWaRh6wCYIbvBDf7BhTiZl5I6cQVoZw9UMWi++nD968tQAAD+8LbxR2HzLRY99ySxutdJJ4IAo3dk2igB3q9wa4KAhZsvu3S5GuNEvuW1PlV1REW/srz/QkrhyD6NuQ3kUA/tHi3aPECBNOTArZavMnRQMEbpTkwpOv7plM7e6IPsNJmOk+DNmd+tlbDTtKeLdOOvuMxZrO1ShCrpbg7CbnFyqRhT4zWubzKbBP3o9zPItggP56RNhtdVh7CseZQW5639vd5D6+Jfqml4zeLfTPSRf2Rjx+7ZRJ/Xc3OreSBYK02RZ2PeRk/pQd693nLl7zhldpz4lDSZB9tDg5pKjTN5NV4p2H98gYRI0bUoQruYxzpt6zA2v00ooGZDQ27bPeY8eTfw/J5sIMxfxVjCmACIdbsXpVhB0E/pxRy4j+Q3iNqCFcHUiyFIrFMa5I6SxrUhPDnrq8FUTtqmmIKs8KQmDY22rv/kKujcH/f5Ga0uTY5g/w9tpXghjN7ex0/3PbEqr4gltm9K2ftzmTtDwo4v78EfmOAAAA==';
  function Ct(e, t, n) {
    let { service: o } = t,
      { pageId: s } = t;
    const c = () => ye().clickService(s, o.uuid);
    return (
      (e.$$set = (r) => {
        'service' in r && n(0, (o = r.service)), 'pageId' in r && n(2, (s = r.pageId));
      }),
      [o, c, s]
    );
  }
  class Lt extends ue {
    constructor(t) {
      super(), ce(this, t, Ct, Pt, K, { service: 0, pageId: 2 }, Nt);
    }
  }
  function Bt(e) {
    te(
      e,
      'svelte-2b0m9n',
      'div.svelte-2b0m9n{display:flex;justify-content:space-between}input.svelte-2b0m9n{flex-grow:1;height:50px;font-size:14px;padding:10px 20px;background:none;border:none;outline:none;box-shadow:none}button.svelte-2b0m9n{height:50px;padding:0 20px;font-size:14px;font-weight:600;color:#000;background:transparent;border:none;outline:none;cursor:pointer}button.svelte-2b0m9n:hover{color:#555}button.svelte-2b0m9n:focus{color:#0b0bde}',
    );
  }
  function Ot(e) {
    let t, n, o, s, c, r;
    return {
      c() {
        (t = w('div')),
          (n = w('input')),
          (o = R()),
          (s = w('button')),
          (s.textContent = 'Subscribe'),
          v(n, 'placeholder', 'Your Email...'),
          v(n, 'type', 'text'),
          v(n, 'class', 'svelte-2b0m9n'),
          v(s, 'class', 'svelte-2b0m9n'),
          v(t, 'class', 'svelte-2b0m9n');
      },
      m(i, l) {
        E(i, t, l),
          y(t, n),
          Pe(n, e[0]),
          y(t, o),
          y(t, s),
          c || ((r = [L(n, 'input', e[3]), L(s, 'click', e[1])]), (c = !0));
      },
      p(i, [l]) {
        l & 1 && n.value !== i[0] && Pe(n, i[0]);
      },
      i: b,
      o: b,
      d(i) {
        i && z(t), (c = !1), O(r);
      },
    };
  }
  function Rt(e, t, n) {
    let { article: o } = t,
      s = '';
    const c = async () => {
      try {
        return (await ye().subscribe(o.page_id, s)).status == 200
          ? (n(0, (s = '')), console.log('success'))
          : console.log('error');
      } catch (i) {
        console.log('error', i);
        return;
      }
    };
    function r() {
      (s = this.value), n(0, s);
    }
    return (
      (e.$$set = (i) => {
        'article' in i && n(2, (o = i.article));
      }),
      [s, c, o, r]
    );
  }
  class jt extends ue {
    constructor(t) {
      super(), ce(this, t, Rt, Ot, K, { article: 2 }, Bt);
    }
  }
  function qe(e) {
    var t = /</g,
      n = />/g,
      o = /\t|\r|\uf8ff/g,
      s = /\\([\\\|`*_{}\[\]()#+\-~])/g,
      c = /^([*\-=_] *){3,}$/gm,
      r = /\n *&gt; *([^]*?)(?=(\n|$){2})/g,
      i = /\n( *)(?:[*\-+]|((\d+)|([a-z])|[A-Z])[.)]) +([^]*?)(?=(\n|$){2})/g,
      l = /<\/(ol|ul)>\n\n<\1>/g,
      u = /(^|[^A-Za-z\d\\])(([*_])|(~)|(\^)|(--)|(\+\+)|`)(\2?)([^<]*?)\2\8(?!\2)(?=\W|_|$)/g,
      p = /\n((```|~~~).*\n?([^]*?)\n?\2|((    .*?\n)+))/g,
      a = /((!?)\[(.*?)\]\((.*?)( ".*")?\)|\\([\\`*_{}\[\]()#+\-.!~]))/g,
      f = /\n(( *\|.*?\| *\n)+)/g,
      h = /^.*\n( *\|( *\:?-+\:?-+\:? *\|)* *\n|)/,
      m = /.*\n/g,
      g = /\||(.*?[^\\])\|/g,
      N = /(?=^|>|\n)([>\s]*?)(#{1,6}) (.*?)( #*)? *(?=\n|$)/g,
      we = /(?=^|>|\n)\s*\n+([^<]+?)\n+\s*(?=\n|<|$)/g,
      ze = /-\d+\uf8ff/g;
    function M(_, k) {
      e = e.replace(_, k);
    }
    function d(_, k) {
      return '<' + _ + '>' + k + '</' + _ + '>';
    }
    function T(_) {
      return _.replace(r, function (k, I) {
        return d('blockquote', T(D(I.replace(/^ *&gt; */gm, ''))));
      });
    }
    function et(_) {
      return _.replace(i, function (k, I, A, $, X, H) {
        var U = d(
          'li',
          D(
            H.split(
              RegExp(
                `
 ?` +
                  I +
                  '(?:(?:\\d+|[a-zA-Z])[.)]|[*\\-+]) +',
                'g',
              ),
            )
              .map(et)
              .join('</li><li>'),
          ),
        );
        return (
          `
` +
          (A
            ? '<ol start="' +
              ($
                ? A + '">'
                : parseInt(A, 36) -
                  9 +
                  '" style="list-style-type:' +
                  (X ? 'low' : 'upp') +
                  'er-alpha">') +
              U +
              '</ol>'
            : d('ul', U))
        );
      });
    }
    function D(_) {
      return _.replace(u, function (k, I, A, $, X, H, U, Gt, tt, Wt) {
        return (
          I +
          d(
            $
              ? tt
                ? 'strong'
                : 'em'
              : X
              ? tt
                ? 's'
                : 'sub'
              : H
              ? 'sup'
              : U
              ? 'small'
              : Gt
              ? 'big'
              : 'code',
            D(Wt),
          )
        );
      });
    }
    function ge(_) {
      return _.replace(s, '$1');
    }
    var ke = [],
      me = 0;
    return (
      (e =
        `
` +
        e +
        `
`),
      M(t, '&lt;'),
      M(n, '&gt;'),
      M(o, '  '),
      (e = T(e)),
      M(c, '<hr/>'),
      (e = et(e)),
      M(l, ''),
      M(p, function (_, k, I, A, $) {
        return (ke[--me] = d('pre', d('code', A || $.replace(/^    /gm, '')))), me + '';
      }),
      M(a, function (_, k, I, A, $, X, H) {
        return (
          (ke[--me] = $
            ? I
              ? '<img src="' + $ + '" alt="' + A + '"/>'
              : '<a href="' + $ + '">' + ge(D(A)) + '</a>'
            : H),
          me + ''
        );
      }),
      M(f, function (_, k) {
        var I = k.match(h)[1];
        return (
          `
` +
          d(
            'table',
            k.replace(m, function (A, $) {
              return A == I
                ? ''
                : d(
                    'tr',
                    A.replace(g, function (X, H, U) {
                      return U ? d(I && !$ ? 'th' : 'td', ge(D(H || ''))) : '';
                    }),
                  );
            }),
          )
        );
      }),
      M(N, function (_, k, I, A) {
        return k + d('h' + I.length, ge(D(A)));
      }),
      M(we, function (_, k) {
        return d('p', ge(D(k)));
      }),
      M(ze, function (_) {
        return ke[parseInt(_)];
      }),
      e.trim()
    );
  }
  function Dt(e) {
    te(
      e,
      'svelte-1ympp8s',
      `.getsummer-btn.svelte-1ympp8s{-webkit-user-select:none;-moz-user-select:none;user-select:none;border-radius:1.5rem;font-size:15px;line-height:22px;--tw-text-opacity:1;color:rgb(255 255 255 / var(--tw-text-opacity));padding:4px 12px;position:fixed;transition:opacity 0.3s;left:calc(50% - 50px);bottom:20px;border:1px solid rgba(255, 255, 255, 0.2);background:rgba(0, 0, 0, 0.85);box-shadow:0 36px 60px 0 rgba(0, 0, 0, 0.18), 0 13.902px 18.888px 0 rgba(0, 0, 0, 0.12), 0 6.929px 11.218px 0 rgba(0, 0, 0, 0.1), 0 3.621px 7.444px 0 rgba(0, 0, 0, 0.08), 0 1.769px 4.735px 0 rgba(0, 0, 0, 0.06), 0 0.664px 2.345px 0 rgba(0, 0, 0, 0.03);-webkit-backdrop-filter:blur(4px);backdrop-filter:blur(4px)
}`,
    );
  }
  function Qe(e, t, n) {
    const o = e.slice();
    return (o[17] = t[n]), o;
  }
  function Ht(e) {
    let t;
    return {
      c() {
        t = Y('Summorize');
      },
      m(n, o) {
        E(n, t, o);
      },
      d(n) {
        n && z(t);
      },
    };
  }
  function Ft(e) {
    let t, n;
    return {
      c() {
        (t = w('span')),
          (n = Y(`
    Summorizing`)),
          v(t, 'class', 'loading loading-spinner loading-xs');
      },
      m(o, s) {
        E(o, t, s), E(o, n, s);
      },
      d(o) {
        o && (z(t), z(n));
      },
    };
  }
  function Ze(e) {
    let t, n, o;
    function s(r) {
      e[12](r);
    }
    let c = { $$slots: { footer: [Qt], default: [qt] }, $$scope: { ctx: e } };
    return (
      e[2] !== void 0 && (c.showModal = e[2]),
      (t = new $t({ props: c })),
      G.push(() => je(t, 'showModal', s)),
      t.$on('close', e[9]),
      {
        c() {
          xe(t.$$.fragment);
        },
        m(r, i) {
          ie(t, r, i), (o = !0);
        },
        p(r, i) {
          const l = {};
          i & 1048603 && (l.$$scope = { dirty: i, ctx: r }),
            !n && i & 4 && ((n = !0), (l.showModal = r[2]), Be(() => (n = !1))),
            t.$set(l);
        },
        i(r) {
          o || (x(t.$$.fragment, r), (o = !0));
        },
        o(r) {
          S(t.$$.fragment, r), (o = !1);
        },
        d(r) {
          le(t, r);
        },
      }
    );
  }
  function Ue(e) {
    let t,
      n,
      o = Re(e[4]),
      s = [];
    for (let r = 0; r < o.length; r += 1) s[r] = Ke(Qe(e, o, r));
    const c = (r) =>
      S(s[r], 1, 1, () => {
        s[r] = null;
      });
    return {
      c() {
        for (let r = 0; r < s.length; r += 1) s[r].c();
        t = ne();
      },
      m(r, i) {
        for (let l = 0; l < s.length; l += 1) s[l] && s[l].m(r, i);
        E(r, t, i), (n = !0);
      },
      p(r, i) {
        if (i & 17) {
          o = Re(r[4]);
          let l;
          for (l = 0; l < o.length; l += 1) {
            const u = Qe(r, o, l);
            s[l]
              ? (s[l].p(u, i), x(s[l], 1))
              : ((s[l] = Ke(u)), s[l].c(), x(s[l], 1), s[l].m(t.parentNode, t));
          }
          for (se(), l = o.length; l < s.length; l += 1) c(l);
          re();
        }
      },
      i(r) {
        if (!n) {
          for (let i = 0; i < o.length; i += 1) x(s[i]);
          n = !0;
        }
      },
      o(r) {
        s = s.filter(Boolean);
        for (let i = 0; i < s.length; i += 1) S(s[i]);
        n = !1;
      },
      d(r) {
        r && z(t), rt(s, r);
      },
    };
  }
  function Ke(e) {
    let t, n;
    return (
      (t = new Lt({ props: { service: e[17], pageId: e[0].page_id } })),
      {
        c() {
          xe(t.$$.fragment);
        },
        m(o, s) {
          ie(t, o, s), (n = !0);
        },
        p(o, s) {
          const c = {};
          s & 16 && (c.service = o[17]), s & 1 && (c.pageId = o[0].page_id), t.$set(c);
        },
        i(o) {
          n || (x(t.$$.fragment, o), (n = !0));
        },
        o(o) {
          S(t.$$.fragment, o), (n = !1);
        },
        d(o) {
          le(t, o);
        },
      }
    );
  }
  function qt(e) {
    let t,
      n = qe(e[3]) + '',
      o,
      s,
      c,
      r = e[1].features.suggestion === !0 && e[4].length > 0 && Ue(e);
    return {
      c() {
        (t = new pt(!1)), (o = R()), r && r.c(), (s = ne()), (t.a = o);
      },
      m(i, l) {
        t.m(n, i, l), E(i, o, l), r && r.m(i, l), E(i, s, l), (c = !0);
      },
      p(i, l) {
        (!c || l & 8) && n !== (n = qe(i[3]) + '') && t.p(n),
          i[1].features.suggestion === !0 && i[4].length > 0
            ? r
              ? (r.p(i, l), l & 18 && x(r, 1))
              : ((r = Ue(i)), r.c(), x(r, 1), r.m(s.parentNode, s))
            : r &&
              (se(),
              S(r, 1, 1, () => {
                r = null;
              }),
              re());
      },
      i(i) {
        c || (x(r), (c = !0));
      },
      o(i) {
        S(r), (c = !1);
      },
      d(i) {
        i && (t.d(), z(o), z(s)), r && r.d(i);
      },
    };
  }
  function Ye(e) {
    let t, n, o;
    function s(r) {
      e[11](r);
    }
    let c = {};
    return (
      e[0] !== void 0 && (c.article = e[0]),
      (t = new jt({ props: c })),
      G.push(() => je(t, 'article', s)),
      {
        c() {
          xe(t.$$.fragment);
        },
        m(r, i) {
          ie(t, r, i), (o = !0);
        },
        p(r, i) {
          const l = {};
          !n && i & 1 && ((n = !0), (l.article = r[0]), Be(() => (n = !1))), t.$set(l);
        },
        i(r) {
          o || (x(t.$$.fragment, r), (o = !0));
        },
        o(r) {
          S(t.$$.fragment, r), (o = !1);
        },
        d(r) {
          le(t, r);
        },
      }
    );
  }
  function Qt(e) {
    let t,
      n,
      o = e[1].features.subscription === !0 && Ye(e);
    return {
      c() {
        o && o.c(), (t = ne());
      },
      m(s, c) {
        o && o.m(s, c), E(s, t, c), (n = !0);
      },
      p(s, c) {
        s[1].features.subscription === !0
          ? o
            ? (o.p(s, c), c & 2 && x(o, 1))
            : ((o = Ye(s)), o.c(), x(o, 1), o.m(t.parentNode, t))
          : o &&
            (se(),
            S(o, 1, 1, () => {
              o = null;
            }),
            re());
      },
      i(s) {
        n || (x(o), (n = !0));
      },
      o(s) {
        S(o), (n = !1);
      },
      d(s) {
        s && z(t), o && o.d(s);
      },
    };
  }
  function Zt(e) {
    let t, n, o, s, c, r;
    function i(a, f) {
      return a[5] ? Ft : Ht;
    }
    let l = i(e),
      u = l(e),
      p = e[6] && Ze(e);
    return {
      c() {
        (t = w('button')),
          u.c(),
          (n = R()),
          p && p.c(),
          (o = ne()),
          v(t, 'class', 'getsummer-btn svelte-1ympp8s'),
          Ce(t, 'opacity', e[7].opacity);
      },
      m(a, f) {
        E(a, t, f),
          u.m(t, null),
          E(a, n, f),
          p && p.m(a, f),
          E(a, o, f),
          (s = !0),
          c || ((r = L(t, 'click', e[8])), (c = !0));
      },
      p(a, [f]) {
        l !== (l = i(a)) && (u.d(1), (u = l(a)), u && (u.c(), u.m(t, null))),
          (!s || f & 128) && Ce(t, 'opacity', a[7].opacity),
          a[6]
            ? p
              ? (p.p(a, f), f & 64 && x(p, 1))
              : ((p = Ze(a)), p.c(), x(p, 1), p.m(o.parentNode, o))
            : p &&
              (se(),
              S(p, 1, 1, () => {
                p = null;
              }),
              re());
      },
      i(a) {
        s || (x(p), (s = !0));
      },
      o(a) {
        S(p), (s = !1);
      },
      d(a) {
        a && (z(t), z(n), z(o)), u.d(), p && p.d(a), (c = !1), r();
      },
    };
  }
  function Ut() {
    return { opacity: 0 };
  }
  function Kt(e, t, n) {
    let o = !1,
      { projectId: s } = t,
      { settings: c } = t,
      { article: r } = t,
      i = '',
      l = [],
      u = !1,
      p = !1,
      a = !1,
      f = Ut();
    const h = ye(s);
    dt(async () => {
      a || (n(7, (f = { opacity: 1 })), n(6, (a = !0)));
    });
    const m = (d = 100) => {
        setTimeout(() => {
          console.log(c, i), n(2, (o = !0)), n(7, (f.opacity = 0), f);
        }, d);
      },
      g = () => {
        if (!p) {
          if (i) return m();
          n(5, (p = !0)), (u = !1);
          try {
            const d = h.getSummary(r.page_id);
            d.result.subscribe((T) => {
              n(3, (i += T));
            }),
              d.isCompleted.subscribe((T) => {
                T === !0 && ((u = !0), N());
              }),
              m(100);
          } catch {
            n(5, (p = !1));
          }
        }
      },
      N = async () => {
        var d;
        if (u)
          try {
            const T = await h.getServices(r.page_id);
            console.log(T),
              (d = T.body) != null && d.hasOwnProperty('services') && n(4, (l = T.body.services));
          } catch (T) {
            console.log(T);
          }
      },
      we = () => {
        n(5, (p = !1)), n(2, (o = !1)), setTimeout(() => n(7, (f.opacity = 1), f), 500);
      };
    function ze(d) {
      (r = d), n(0, r);
    }
    function M(d) {
      (o = d), n(2, o);
    }
    return (
      (e.$$set = (d) => {
        'projectId' in d && n(10, (s = d.projectId)),
          'settings' in d && n(1, (c = d.settings)),
          'article' in d && n(0, (r = d.article));
      }),
      [r, c, o, i, l, p, a, f, g, we, s, ze, M]
    );
  }
  class Yt extends ue {
    constructor(t) {
      super(), ce(this, t, Kt, Zt, K, { projectId: 10, settings: 1, article: 0 }, Dt);
    }
  }
  let W, Je, Ve;
  const Jt = (e) => {
      console.log(`%c${e}`, 'background: #FFEFE7; padding: 2px 10px;');
    },
    Ge = () => {
      W && typeof W.$destroy == 'function' && W.$destroy(), (W = void 0);
    },
    Vt = (e, t, n) => {
      const o = 'getsummer-' + e;
      let s = document.getElementById(o);
      return (
        s
          ? s.innerHTML !== '' && (s.innerHTML = '')
          : ((s = document.createElement('div')), (s.id = o), document.body.appendChild(s)),
        Ge(),
        (W = new Yt({ target: s, props: { projectId: e, settings: t, article: n } })),
        o
      );
    },
    We = (e, t, n = 100) => {
      const o = new URL(t).pathname,
        s = e.settings;
      clearInterval(Je),
        clearTimeout(Ve),
        !(typeof s.paths.find((r) => o.indexOf(r) === 0) > 'u') &&
          (Ve = setTimeout(() => {
            wt(e.id, t)
              .then((r) => {
                const i = r.body;
                if (!i) return Jt("GetSummer: Skipping page as there's no article");
                if ('code' in i) return console.error('GetSummer', r);
                const l = () => Vt(e.id, s, i.article),
                  u = l();
                Je = setInterval(() => {
                  document.getElementById(u) === null &&
                    (console.log('app destroyed, reinstalling'), Ge(), l());
                }, 2e3);
              })
              .catch((r) => {
                console.error('initApp', r);
              });
          }, n));
    },
    Xe = { id: window.GetSummer.id, settings: window.GetSummer.settings };
  let de = location.href;
  We(Xe, de),
    new MutationObserver(function () {
      location.href !== de && ((de = location.href), We(Xe, de, 1e3));
    }).observe(document, { subtree: !0, childList: !0 });
});
