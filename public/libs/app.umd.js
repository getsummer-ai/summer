(function (_) {
  typeof define == 'function' && define.amd ? define(_) : _();
})(function () {
  'use strict';
  var Xt = Object.defineProperty;
  var en = (_, D, $) =>
    D in _ ? Xt(_, D, { enumerable: !0, configurable: !0, writable: !0, value: $ }) : (_[D] = $);
  var P = (_, D, $) => (en(_, typeof D != 'symbol' ? D + '' : D, $), $);
  function _() {}
  function D(e, t) {
    for (const n in t) e[n] = t[n];
    return e;
  }
  function $(e) {
    return e();
  }
  function ze() {
    return Object.create(null);
  }
  function F(e) {
    e.forEach($);
  }
  function Se(e) {
    return typeof e == 'function';
  }
  function Q(e, t) {
    return e != e ? t == t : e !== t || (e && typeof e == 'object') || typeof e == 'function';
  }
  let te;
  function Ae(e, t) {
    return e === t ? !0 : (te || (te = document.createElement('a')), (te.href = t), e === te.href);
  }
  function rt(e) {
    return Object.keys(e).length === 0;
  }
  function Ce(e, t, n, r) {
    if (e) {
      const o = Be(e, t, n, r);
      return e[0](o);
    }
  }
  function Be(e, t, n, r) {
    return e[1] && r ? D(n.ctx.slice(), e[1](r(t))) : n.ctx;
  }
  function Me(e, t, n, r) {
    if (e[2] && r) {
      const o = e[2](r(n));
      if (t.dirty === void 0) return o;
      if (typeof o == 'object') {
        const a = [],
          s = Math.max(t.dirty.length, o.length);
        for (let i = 0; i < s; i += 1) a[i] = t.dirty[i] | o[i];
        return a;
      }
      return t.dirty | o;
    }
    return t.dirty;
  }
  function Ie(e, t, n, r, o, a) {
    if (o) {
      const s = Be(t, n, r, a);
      e.p(s, o);
    }
  }
  function Te(e) {
    if (e.ctx.length > 32) {
      const t = [],
        n = e.ctx.length / 32;
      for (let r = 0; r < n; r++) t[r] = -1;
      return t;
    }
    return -1;
  }
  function w(e, t) {
    e.appendChild(t);
  }
  function ne(e, t, n) {
    const r = ot(e);
    if (!r.getElementById(t)) {
      const o = k('style');
      (o.id = t), (o.textContent = n), st(r, o);
    }
  }
  function ot(e) {
    if (!e) return document;
    const t = e.getRootNode ? e.getRootNode() : e.ownerDocument;
    return t && t.host ? t : e.ownerDocument;
  }
  function st(e, t) {
    return w(e.head || e, t), t.sheet;
  }
  function E(e, t, n) {
    e.insertBefore(t, n || null);
  }
  function x(e) {
    e.parentNode && e.parentNode.removeChild(e);
  }
  function it(e, t) {
    for (let n = 0; n < e.length; n += 1) e[n] && e[n].d(t);
  }
  function k(e) {
    return document.createElement(e);
  }
  function lt(e) {
    return document.createElementNS('http://www.w3.org/2000/svg', e);
  }
  function Y(e) {
    return document.createTextNode(e);
  }
  function N() {
    return Y(' ');
  }
  function re() {
    return Y('');
  }
  function L(e, t, n, r) {
    return e.addEventListener(t, n, r), () => e.removeEventListener(t, n, r);
  }
  function at(e) {
    return function (t) {
      return t.stopPropagation(), e.call(this, t);
    };
  }
  function ct(e) {
    return function (t) {
      t.target === this && e.call(this, t);
    };
  }
  function m(e, t, n) {
    n == null ? e.removeAttribute(t) : e.getAttribute(t) !== n && e.setAttribute(t, n);
  }
  function ut(e) {
    return Array.from(e.childNodes);
  }
  function ft(e, t) {
    (t = '' + t), e.data !== t && (e.data = t);
  }
  function De(e, t) {
    e.value = t ?? '';
  }
  function $e(e, t, n, r) {
    n == null ? e.style.removeProperty(t) : e.style.setProperty(t, n, r ? 'important' : '');
  }
  function dt(e, t, { bubbles: n = !1, cancelable: r = !1 } = {}) {
    return new CustomEvent(e, { detail: t, bubbles: n, cancelable: r });
  }
  class pt {
    constructor(t = !1) {
      P(this, 'is_svg', !1);
      P(this, 'e');
      P(this, 'n');
      P(this, 't');
      P(this, 'a');
      (this.is_svg = t), (this.e = this.n = null);
    }
    c(t) {
      this.h(t);
    }
    m(t, n, r = null) {
      this.e ||
        (this.is_svg
          ? (this.e = lt(n.nodeName))
          : (this.e = k(n.nodeType === 11 ? 'TEMPLATE' : n.nodeName)),
        (this.t = n.tagName !== 'TEMPLATE' ? n : n.content),
        this.c(t)),
        this.i(r);
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
      this.n.forEach(x);
    }
  }
  let U;
  function G(e) {
    U = e;
  }
  function Ne() {
    if (!U) throw new Error('Function called outside component initialization');
    return U;
  }
  function ht(e) {
    Ne().$$.on_mount.push(e);
  }
  function gt() {
    const e = Ne();
    return (t, n, { cancelable: r = !1 } = {}) => {
      const o = e.$$.callbacks[t];
      if (o) {
        const a = dt(t, n, { cancelable: r });
        return (
          o.slice().forEach((s) => {
            s.call(e, a);
          }),
          !a.defaultPrevented
        );
      }
      return !0;
    };
  }
  function mt(e, t) {
    const n = e.$$.callbacks[t.type];
    n && n.slice().forEach((r) => r.call(this, t));
  }
  const Z = [],
    J = [];
  let j = [];
  const me = [],
    bt = Promise.resolve();
  let be = !1;
  function _t() {
    be || ((be = !0), bt.then(Pe));
  }
  function _e(e) {
    j.push(e);
  }
  function Le(e) {
    me.push(e);
  }
  const ve = new Set();
  let K = 0;
  function Pe() {
    if (K !== 0) return;
    const e = U;
    do {
      try {
        for (; K < Z.length; ) {
          const t = Z[K];
          K++, G(t), vt(t.$$);
        }
      } catch (t) {
        throw ((Z.length = 0), (K = 0), t);
      }
      for (G(null), Z.length = 0, K = 0; J.length; ) J.pop()();
      for (let t = 0; t < j.length; t += 1) {
        const n = j[t];
        ve.has(n) || (ve.add(n), n());
      }
      j.length = 0;
    } while (Z.length);
    for (; me.length; ) me.pop()();
    (be = !1), ve.clear(), G(e);
  }
  function vt(e) {
    if (e.fragment !== null) {
      e.update(), F(e.before_update);
      const t = e.dirty;
      (e.dirty = [-1]), e.fragment && e.fragment.p(e.ctx, t), e.after_update.forEach(_e);
    }
  }
  function wt(e) {
    const t = [],
      n = [];
    j.forEach((r) => (e.indexOf(r) === -1 ? t.push(r) : n.push(r))), n.forEach((r) => r()), (j = t);
  }
  const oe = new Set();
  let O;
  function se() {
    O = { r: 0, c: [], p: O };
  }
  function ie() {
    O.r || F(O.c), (O = O.p);
  }
  function y(e, t) {
    e && e.i && (oe.delete(e), e.i(t));
  }
  function A(e, t, n, r) {
    if (e && e.o) {
      if (oe.has(e)) return;
      oe.add(e),
        O.c.push(() => {
          oe.delete(e), r && (n && e.d(1), r());
        }),
        e.o(t);
    } else r && r();
  }
  function Fe(e) {
    return (e == null ? void 0 : e.length) !== void 0 ? e : Array.from(e);
  }
  function Oe(e, t, n) {
    const r = e.$$.props[t];
    r !== void 0 && ((e.$$.bound[r] = n), n(e.$$.ctx[r]));
  }
  function we(e) {
    e && e.c();
  }
  function le(e, t, n) {
    const { fragment: r, after_update: o } = e.$$;
    r && r.m(t, n),
      _e(() => {
        const a = e.$$.on_mount.map($).filter(Se);
        e.$$.on_destroy ? e.$$.on_destroy.push(...a) : F(a), (e.$$.on_mount = []);
      }),
      o.forEach(_e);
  }
  function ae(e, t) {
    const n = e.$$;
    n.fragment !== null &&
      (wt(n.after_update),
      F(n.on_destroy),
      n.fragment && n.fragment.d(t),
      (n.on_destroy = n.fragment = null),
      (n.ctx = []));
  }
  function kt(e, t) {
    e.$$.dirty[0] === -1 && (Z.push(e), _t(), e.$$.dirty.fill(0)),
      (e.$$.dirty[(t / 31) | 0] |= 1 << t % 31);
  }
  function ce(e, t, n, r, o, a, s = null, i = [-1]) {
    const l = U;
    G(e);
    const c = (e.$$ = {
      fragment: null,
      ctx: [],
      props: a,
      update: _,
      not_equal: o,
      bound: ze(),
      on_mount: [],
      on_destroy: [],
      on_disconnect: [],
      before_update: [],
      after_update: [],
      context: new Map(t.context || (l ? l.$$.context : [])),
      callbacks: ze(),
      dirty: i,
      skip_bound: !1,
      root: t.target || l.$$.root,
    });
    s && s(c.root);
    let b = !1;
    if (
      ((c.ctx = n
        ? n(e, t.props || {}, (p, u, ...f) => {
            const d = f.length ? f[0] : u;
            return (
              c.ctx &&
                o(c.ctx[p], (c.ctx[p] = d)) &&
                (!c.skip_bound && c.bound[p] && c.bound[p](d), b && kt(e, p)),
              u
            );
          })
        : []),
      c.update(),
      (b = !0),
      F(c.before_update),
      (c.fragment = r ? r(c.ctx) : !1),
      t.target)
    ) {
      if (t.hydrate) {
        const p = ut(t.target);
        c.fragment && c.fragment.l(p), p.forEach(x);
      } else c.fragment && c.fragment.c();
      t.intro && y(e.$$.fragment), le(e, t.target, t.anchor), Pe();
    }
    G(l);
  }
  class ue {
    constructor() {
      P(this, '$$');
      P(this, '$$set');
    }
    $destroy() {
      ae(this, 1), (this.$destroy = _);
    }
    $on(t, n) {
      if (!Se(n)) return _;
      const r = this.$$.callbacks[t] || (this.$$.callbacks[t] = []);
      return (
        r.push(n),
        () => {
          const o = r.indexOf(n);
          o !== -1 && r.splice(o, 1);
        }
      );
    }
    $set(t) {
      this.$$set && !rt(t) && ((this.$$.skip_bound = !0), this.$$set(t), (this.$$.skip_bound = !1));
    }
  }
  const yt = '4';
  typeof window < 'u' && (window.__svelte || (window.__svelte = { v: new Set() })).v.add(yt);
  const V = [];
  function Re(e, t = _) {
    let n;
    const r = new Set();
    function o(i) {
      if (Q(e, i) && ((e = i), n)) {
        const l = !V.length;
        for (const c of r) c[1](), V.push(c, e);
        if (l) {
          for (let c = 0; c < V.length; c += 2) V[c][0](V[c + 1]);
          V.length = 0;
        }
      }
    }
    function a(i) {
      o(i(e));
    }
    function s(i, l = _) {
      const c = [i, l];
      return (
        r.add(c),
        r.size === 1 && (n = t(o, a) || _),
        i(e),
        () => {
          r.delete(c), r.size === 0 && n && (n(), (n = null));
        }
      );
    }
    return { set: o, update: a, subscribe: s };
  }
  const W = 'https://app.getsummer.ai',
    fe = async (e, t, n = null) => {
      const r = await fetch(e, {
        method: n == null ? 'GET' : 'POST',
        mode: 'cors',
        headers: { 'Content-Type': 'application/json', 'Api-Key': t },
        ...(n == null ? {} : { body: JSON.stringify(n) }),
      });
      let o = await r.text();
      if (o)
        try {
          return (o = JSON.parse(o)), { status: r.status, body: o };
        } catch (a) {
          console.log(a);
        }
      return { status: r.status, body: null };
    },
    xt = async (e, t) => fe(`${W}/api/v1/button/init`, e, { s: t }),
    Et = (e, t) => {
      const n = new EventSource(`${W}/api/v1/pages/${t}/summary?key=${e}`),
        r = Re(''),
        o = Re(!1);
      return (
        n.addEventListener('message', (a) => {
          r.set(a.data);
        }),
        n.addEventListener('error', (a) => {
          a.eventPhase === EventSource.CLOSED && (n.close(), o.set(!0));
        }),
        { result: r, isCompleted: o }
      );
    },
    zt = (e, t) => fe(`${W}/api/v1/pages/${t}/products`, e),
    St = (e, t, n) => fe(`${W}/api/v1/pages/${t}/products/${n}/click`, e, {}),
    At = (e, t, n) => fe(`${W}/api/v1/pages/${t}/subscribe`, e, { email: n });
  let de;
  const ke = (e) => {
    if (!e && de) return de;
    if (!e) throw new Error('projectId is required');
    return (
      (de = {
        clickService: St.bind(null, e),
        getServices: zt.bind(null, e),
        getSummary: Et.bind(null, e),
        subscribe: At.bind(null, e),
      }),
      de
    );
  };
  function Ct(e) {
    ne(
      e,
      'svelte-1w52nkd',
      'dialog.svelte-1w52nkd.svelte-1w52nkd{width:100%;max-width:560px;padding:0;border:none;border-radius:16px;background:#FFF;font-size:16px;line-height:22px;font-style:normal;font-weight:400}dialog.svelte-1w52nkd .dialog.svelte-1w52nkd{position:relative;padding:60px 0 0}dialog.svelte-1w52nkd .body.svelte-1w52nkd{position:relative;max-height:70vh;overflow-y:auto;padding:0 30px 30px 30px;transition:max-height 0.5s, height 0.5s}@media(max-height: 40px){dialog.svelte-1w52nkd .body.svelte-1w52nkd{max-height:20vh}}@media(max-height: 500px){dialog.svelte-1w52nkd .body.svelte-1w52nkd{max-height:40vh}}@media(max-height: 650px){dialog.svelte-1w52nkd .body.svelte-1w52nkd{max-height:50vh}}dialog.svelte-1w52nkd .body.svelte-1w52nkd ul{margin:0;padding:0 0 0 15px;list-style-type:disc;list-style-position:outside}dialog.svelte-1w52nkd .body.svelte-1w52nkd li{margin:0 0 8px 0;padding:0}dialog.svelte-1w52nkd .body.svelte-1w52nkd p{margin:0 0 8px 0;padding:0}dialog.svelte-1w52nkd .body.svelte-1w52nkd p:first-child{margin-bottom:12px}dialog.svelte-1w52nkd .footer.svelte-1w52nkd{position:relative;z-index:10;min-height:3rem;box-shadow:0px -25px 14px -11px #fff;-webkit-box-shadow:0px -25px 14px -11px #fff;-moz-box-shadow:0px -25px 14px -11px #fff;border-top:1px solid #EFEFEF}dialog.svelte-1w52nkd.svelte-1w52nkd::backdrop{background:rgba(0, 0, 0, 0.3)}dialog[open].svelte-1w52nkd.svelte-1w52nkd{animation:svelte-1w52nkd-zoom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)}@keyframes svelte-1w52nkd-zoom{from{transform:scale(0.95)}to{transform:scale(1)}}dialog[open].svelte-1w52nkd.svelte-1w52nkd::backdrop{animation:svelte-1w52nkd-fade 0.2s ease-out}@keyframes svelte-1w52nkd-fade{from{opacity:0}to{opacity:1}}.close.svelte-1w52nkd.svelte-1w52nkd{position:absolute;top:12px;right:12px;display:inline-block;width:24px;height:24px;text-align:center;cursor:pointer;background:rgba(0, 0, 0, 0.05);border-radius:50%;transition:background-color 0.1s}.close.svelte-1w52nkd.svelte-1w52nkd:hover{background:#e1e1e1}.close__x.svelte-1w52nkd.svelte-1w52nkd{position:relative;top:0;left:-0.5px;display:inline-block;width:10px;height:10px}.close__x.svelte-1w52nkd.svelte-1w52nkd::before,.close__x.svelte-1w52nkd.svelte-1w52nkd::after{position:absolute;width:1px;height:10px;content:" ";background-color:black}.close__x.svelte-1w52nkd.svelte-1w52nkd::before{transform:rotate(-45deg)}.close__x.svelte-1w52nkd.svelte-1w52nkd::after{transform:rotate(45deg)}.close.svelte-1w52nkd.svelte-1w52nkd:active{top:11px;right:11px;width:26px;height:26px;background:#e1e1e1}',
    );
  }
  const Bt = (e) => ({}),
    He = (e) => ({});
  function Mt(e) {
    let t, n, r, o, a, s, i, l, c, b;
    const p = e[4].default,
      u = Ce(p, e, e[3], null),
      f = e[4].footer,
      d = Ce(f, e, e[3], He);
    return {
      c() {
        (t = k('dialog')),
          (n = k('div')),
          (r = k('button')),
          (r.innerHTML = '<span class="close__x svelte-1w52nkd"></span>'),
          (o = N()),
          (a = k('div')),
          u && u.c(),
          (s = N()),
          (i = k('div')),
          d && d.c(),
          m(r, 'class', 'close svelte-1w52nkd'),
          m(r, 'tabindex', '0'),
          m(a, 'class', 'body svelte-1w52nkd'),
          m(i, 'class', 'footer svelte-1w52nkd'),
          m(n, 'class', 'dialog svelte-1w52nkd'),
          m(t, 'class', 'svelte-1w52nkd');
      },
      m(g, T) {
        E(g, t, T),
          w(t, n),
          w(n, r),
          w(n, o),
          w(n, a),
          u && u.m(a, null),
          w(n, s),
          w(n, i),
          d && d.m(i, null),
          e[7](t),
          (l = !0),
          c ||
            ((b = [
              L(r, 'click', e[6]),
              L(n, 'click', at(e[5])),
              L(t, 'close', e[1]),
              L(t, 'click', ct(e[8])),
            ]),
            (c = !0));
      },
      p(g, [T]) {
        u && u.p && (!l || T & 8) && Ie(u, p, g, g[3], l ? Me(p, g[3], T, null) : Te(g[3]), null),
          d && d.p && (!l || T & 8) && Ie(d, f, g, g[3], l ? Me(f, g[3], T, Bt) : Te(g[3]), He);
      },
      i(g) {
        l || (y(u, g), y(d, g), (l = !0));
      },
      o(g) {
        A(u, g), A(d, g), (l = !1);
      },
      d(g) {
        g && x(t), u && u.d(g), d && d.d(g), e[7](null), (c = !1), F(b);
      },
    };
  }
  function It(e, t, n) {
    let { $$slots: r = {}, $$scope: o } = t;
    const a = gt();
    function s() {
      a('close');
    }
    let { showModal: i = !1 } = t,
      l;
    function c(f) {
      mt.call(this, e, f);
    }
    const b = () => l.close();
    function p(f) {
      J[f ? 'unshift' : 'push'](() => {
        (l = f), n(0, l);
      });
    }
    const u = () => l.close();
    return (
      (e.$$set = (f) => {
        'showModal' in f && n(2, (i = f.showModal)), '$$scope' in f && n(3, (o = f.$$scope));
      }),
      (e.$$.update = () => {
        e.$$.dirty & 5 && l && i && l.showModal();
      }),
      [l, s, i, o, r, c, b, p, u]
    );
  }
  class Tt extends ue {
    constructor(t) {
      super(), ce(this, t, It, Mt, Q, { showModal: 2 }, Ct);
    }
  }
  function Dt(e) {
    ne(
      e,
      'svelte-xrzowf',
      'a.svelte-xrzowf.svelte-xrzowf{font-size:16px;border-radius:12px;border:1px solid #e6e6e9;background:#fff;box-shadow:0 2px 4px 0 #e6e6e9;padding:9px 12px;display:flex;justify-content:space-between;align-items:center;text-decoration:none;color:black;margin-top:20px;animation:svelte-xrzowf-zoom 1s cubic-bezier(0.34, 1.56, 0.64, 1)}a.svelte-xrzowf .body.svelte-xrzowf{display:flex;align-items:center;justify-content:space-between}a.svelte-xrzowf .body img.svelte-xrzowf{width:auto;max-height:45px;border-radius:4px}a.svelte-xrzowf .body .title.svelte-xrzowf{margin-left:1.25rem}a.svelte-xrzowf.svelte-xrzowf:not(:first-of-type){margin-top:10px}a.svelte-xrzowf.svelte-xrzowf:hover{background-color:#f8f8f8}@keyframes svelte-xrzowf-zoom{from{opacity:0.2;transform:scale(0.95)}to{opacity:1;transform:scale(1)}}',
    );
  }
  function $t(e) {
    let t,
      n,
      r,
      o,
      a,
      s,
      i = e[0].name + '',
      l,
      c,
      b,
      p,
      u,
      f;
    return {
      c() {
        (t = k('a')),
          (n = k('div')),
          (r = k('img')),
          (a = N()),
          (s = k('span')),
          (l = Y(i)),
          (c = N()),
          (b = k('div')),
          (b.innerHTML =
            '<svg width="18" height="11" viewBox="0 0 18 11" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M17.208 5.32L12.232 10.296H10.456L14.792 5.944H-0.00799996V4.696H14.824L10.472 0.344H12.248L17.208 5.32Z" fill="black"></path></svg>'),
          m(r, 'alt', 'preview'),
          Ae(r.src, (o = 'data:image/webp;base64,' + (e[0].icon ? e[0].icon : Ze))) ||
            m(r, 'src', o),
          m(r, 'class', 'svelte-xrzowf'),
          m(s, 'class', 'title svelte-xrzowf'),
          m(n, 'class', 'body svelte-xrzowf'),
          m(b, 'class', 'icon'),
          m(t, 'target', '_blank'),
          m(t, 'href', (p = e[0].link)),
          m(t, 'class', 'svelte-xrzowf');
      },
      m(d, g) {
        E(d, t, g),
          w(t, n),
          w(n, r),
          w(n, a),
          w(n, s),
          w(s, l),
          w(t, c),
          w(t, b),
          u || ((f = L(t, 'click', e[1])), (u = !0));
      },
      p(d, [g]) {
        g & 1 &&
          !Ae(r.src, (o = 'data:image/webp;base64,' + (d[0].icon ? d[0].icon : Ze))) &&
          m(r, 'src', o),
          g & 1 && i !== (i = d[0].name + '') && ft(l, i),
          g & 1 && p !== (p = d[0].link) && m(t, 'href', p);
      },
      i: _,
      o: _,
      d(d) {
        d && x(t), (u = !1), f();
      },
    };
  }
  const Ze =
    'UklGRu4BAABXRUJQVlA4IOIBAABQDACdASo+AC0APoU4l0elI6IhMrbeYKAQiWoAnTKvOre08kyAEAntgH4zAZy9vkOgh4JcOf6+UHtoYnnQI0ofxVdaPK953IrCWaRh6wCYIbvBDf7BhTiZl5I6cQVoZw9UMWi++nD968tQAAD+8LbxR2HzLRY99ySxutdJJ4IAo3dk2igB3q9wa4KAhZsvu3S5GuNEvuW1PlV1REW/srz/QkrhyD6NuQ3kUA/tHi3aPECBNOTArZavMnRQMEbpTkwpOv7plM7e6IPsNJmOk+DNmd+tlbDTtKeLdOOvuMxZrO1ShCrpbg7CbnFyqRhT4zWubzKbBP3o9zPItggP56RNhtdVh7CseZQW5639vd5D6+Jfqml4zeLfTPSRf2Rjx+7ZRJ/Xc3OreSBYK02RZ2PeRk/pQd693nLl7zhldpz4lDSZB9tDg5pKjTN5NV4p2H98gYRI0bUoQruYxzpt6zA2v00ooGZDQ27bPeY8eTfw/J5sIMxfxVjCmACIdbsXpVhB0E/pxRy4j+Q3iNqCFcHUiyFIrFMa5I6SxrUhPDnrq8FUTtqmmIKs8KQmDY22rv/kKujcH/f5Ga0uTY5g/w9tpXghjN7ex0/3PbEqr4gltm9K2ftzmTtDwo4v78EfmOAAAA==';
  function Nt(e, t, n) {
    let { service: r } = t,
      { pageId: o } = t;
    const a = () => ke().clickService(o, r.uuid);
    return (
      (e.$$set = (s) => {
        'service' in s && n(0, (r = s.service)), 'pageId' in s && n(2, (o = s.pageId));
      }),
      [r, a, o]
    );
  }
  class Lt extends ue {
    constructor(t) {
      super(), ce(this, t, Nt, $t, Q, { service: 0, pageId: 2 }, Dt);
    }
  }
  function Pt(e) {
    ne(
      e,
      'svelte-2b0m9n',
      'div.svelte-2b0m9n{display:flex;justify-content:space-between}input.svelte-2b0m9n{flex-grow:1;height:50px;font-size:14px;padding:10px 20px;background:none;border:none;outline:none;box-shadow:none}button.svelte-2b0m9n{height:50px;padding:0 20px;font-size:14px;font-weight:600;color:#000;background:transparent;border:none;outline:none;cursor:pointer}button.svelte-2b0m9n:hover{color:#555}button.svelte-2b0m9n:focus{color:#0b0bde}',
    );
  }
  function Ft(e) {
    let t, n, r, o, a, s;
    return {
      c() {
        (t = k('div')),
          (n = k('input')),
          (r = N()),
          (o = k('button')),
          (o.textContent = 'Subscribe'),
          m(n, 'placeholder', 'Your Email...'),
          m(n, 'type', 'text'),
          m(n, 'class', 'svelte-2b0m9n'),
          m(o, 'class', 'svelte-2b0m9n'),
          m(t, 'class', 'svelte-2b0m9n');
      },
      m(i, l) {
        E(i, t, l),
          w(t, n),
          De(n, e[0]),
          w(t, r),
          w(t, o),
          a || ((s = [L(n, 'input', e[3]), L(o, 'click', e[1])]), (a = !0));
      },
      p(i, [l]) {
        l & 1 && n.value !== i[0] && De(n, i[0]);
      },
      i: _,
      o: _,
      d(i) {
        i && x(t), (a = !1), F(s);
      },
    };
  }
  function Ot(e, t, n) {
    let { article: r } = t,
      o = '';
    const a = async () => {
      try {
        return (await ke().subscribe(r.page_id, o)).status == 200
          ? (n(0, (o = '')), console.log('success'))
          : console.log('error');
      } catch (i) {
        console.log('error', i);
        return;
      }
    };
    function s() {
      (o = this.value), n(0, o);
    }
    return (
      (e.$$set = (i) => {
        'article' in i && n(2, (r = i.article));
      }),
      [o, a, r, s]
    );
  }
  class Rt extends ue {
    constructor(t) {
      super(), ce(this, t, Ot, Ft, Q, { article: 2 }, Pt);
    }
  }
  function je(e) {
    var t = /</g,
      n = />/g,
      r = /\t|\r|\uf8ff/g,
      o = /\\([\\\|`*_{}\[\]()#+\-~])/g,
      a = /^([*\-=_] *){3,}$/gm,
      s = /\n *&gt; *([^]*?)(?=(\n|$){2})/g,
      i = /\n( *)(?:[*\-+]|((\d+)|([a-z])|[A-Z])[.)]) +([^]*?)(?=(\n|$){2})/g,
      l = /<\/(ol|ul)>\n\n<\1>/g,
      c = /(^|[^A-Za-z\d\\])(([*_])|(~)|(\^)|(--)|(\+\+)|`)(\2?)([^<]*?)\2\8(?!\2)(?=\W|_|$)/g,
      b = /\n((```|~~~).*\n?([^]*?)\n?\2|((    .*?\n)+))/g,
      p = /((!?)\[(.*?)\]\((.*?)( ".*")?\)|\\([\\`*_{}\[\]()#+\-.!~]))/g,
      u = /\n(( *\|.*?\| *\n)+)/g,
      f = /^.*\n( *\|( *\:?-+\:?-+\:? *\|)* *\n|)/,
      d = /.*\n/g,
      g = /\||(.*?[^\\])\|/g,
      T = /(?=^|>|\n)([>\s]*?)(#{1,6}) (.*?)( #*)? *(?=\n|$)/g,
      ye = /(?=^|>|\n)\s*\n+([^<]+?)\n+\s*(?=\n|<|$)/g,
      xe = /-\d+\uf8ff/g;
    function C(v, z) {
      e = e.replace(v, z);
    }
    function h(v, z) {
      return '<' + v + '>' + z + '</' + v + '>';
    }
    function M(v) {
      return v.replace(s, function (z, B) {
        return h('blockquote', M(R(B.replace(/^ *&gt; */gm, ''))));
      });
    }
    function tt(v) {
      return v.replace(i, function (z, B, S, I, ee, H) {
        var q = h(
          'li',
          R(
            H.split(
              RegExp(
                `
 ?` +
                  B +
                  '(?:(?:\\d+|[a-zA-Z])[.)]|[*\\-+]) +',
                'g',
              ),
            )
              .map(tt)
              .join('</li><li>'),
          ),
        );
        return (
          `
` +
          (S
            ? '<ol start="' +
              (I
                ? S + '">'
                : parseInt(S, 36) -
                  9 +
                  '" style="list-style-type:' +
                  (ee ? 'low' : 'upp') +
                  'er-alpha">') +
              q +
              '</ol>'
            : h('ul', q))
        );
      });
    }
    function R(v) {
      return v.replace(c, function (z, B, S, I, ee, H, q, Jt, nt, Wt) {
        return (
          B +
          h(
            I
              ? nt
                ? 'strong'
                : 'em'
              : ee
              ? nt
                ? 's'
                : 'sub'
              : H
              ? 'sup'
              : q
              ? 'small'
              : Jt
              ? 'big'
              : 'code',
            R(Wt),
          )
        );
      });
    }
    function he(v) {
      return v.replace(o, '$1');
    }
    var Ee = [],
      ge = 0;
    return (
      (e =
        `
` +
        e +
        `
`),
      C(t, '&lt;'),
      C(n, '&gt;'),
      C(r, '  '),
      (e = M(e)),
      C(a, '<hr/>'),
      (e = tt(e)),
      C(l, ''),
      C(b, function (v, z, B, S, I) {
        return (Ee[--ge] = h('pre', h('code', S || I.replace(/^    /gm, '')))), ge + '';
      }),
      C(p, function (v, z, B, S, I, ee, H) {
        return (
          (Ee[--ge] = I
            ? B
              ? '<img src="' + I + '" alt="' + S + '"/>'
              : '<a href="' + I + '">' + he(R(S)) + '</a>'
            : H),
          ge + ''
        );
      }),
      C(u, function (v, z) {
        var B = z.match(f)[1];
        return (
          `
` +
          h(
            'table',
            z.replace(d, function (S, I) {
              return S == B
                ? ''
                : h(
                    'tr',
                    S.replace(g, function (ee, H, q) {
                      return q ? h(B && !I ? 'th' : 'td', he(R(H || ''))) : '';
                    }),
                  );
            }),
          )
        );
      }),
      C(T, function (v, z, B, S) {
        return z + h('h' + B.length, he(R(S)));
      }),
      C(ye, function (v, z) {
        return h('p', he(R(z)));
      }),
      C(xe, function (v) {
        return Ee[parseInt(v)];
      }),
      e.trim()
    );
  }
  function Ht(e) {
    ne(
      e,
      'svelte-153y05y',
      `*{font-family:"Inter", ui-sans-serif, system-ui, sans-serif;box-sizing:border-box;border-width:0;border-style:solid;letter-spacing:-0.01rem}.getsummer-btn.svelte-153y05y.svelte-153y05y{cursor:pointer;-webkit-user-select:none;-moz-user-select:none;user-select:none;border-radius:1.5rem;font-size:15px;line-height:22px;--tw-text-opacity:1;color:rgb(255 255 255 / var(--tw-text-opacity));padding:4px 12px;position:fixed;transition:opacity 0.3s;left:calc(50% - 50px);bottom:20px;border:1px solid rgba(255, 255, 255, 0.2);background:rgba(0, 0, 0, 0.85);box-shadow:0 36px 60px 0 rgba(0, 0, 0, 0.18), 0 13.902px 18.888px 0 rgba(0, 0, 0, 0.12), 0 6.929px 11.218px 0 rgba(0, 0, 0, 0.1), 0 3.621px 7.444px 0 rgba(0, 0, 0, 0.08), 0 1.769px 4.735px 0 rgba(0, 0, 0, 0.06), 0 0.664px 2.345px 0 rgba(0, 0, 0, 0.03);-webkit-backdrop-filter:blur(4px);backdrop-filter:blur(4px)}.getsummer-btn.svelte-153y05y .loading-icon.svelte-153y05y{pointer-events:none;display:inline-block;aspect-ratio:1 / 1;background-color:currentColor;-webkit-mask-size:100%;mask-size:100%;-webkit-mask-repeat:no-repeat;mask-repeat:no-repeat;-webkit-mask-position:center;mask-position:center;-webkit-mask-image:url("data:image/svg+xml,%3Csvg width='24' height='24' stroke='%23000' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cstyle%3E.spinner_V8m1%7Btransform-origin:center;animation:spinner_zKoa 2s linear infinite%7D.spinner_V8m1 circle%7Bstroke-linecap:round;animation:spinner_YpZS 1.5s ease-out infinite%7D%40keyframes spinner_zKoa%7B100%25%7Btransform:rotate(360deg)%7D%7D%40keyframes spinner_YpZS%7B0%25%7Bstroke-dasharray:0 150;stroke-dashoffset:0%7D47.5%25%7Bstroke-dasharray:42 150;stroke-dashoffset:-16%7D95%25%2C100%25%7Bstroke-dasharray:42 150;stroke-dashoffset:-59%7D%7D%3C%2Fstyle%3E%3Cg class='spinner_V8m1'%3E%3Ccircle cx='12' cy='12' r='9.5' fill='none' stroke-width='3'%3E%3C%2Fcircle%3E%3C%2Fg%3E%3C%2Fsvg%3E");mask-image:url("data:image/svg+xml,%3Csvg width='24' height='24' stroke='%23000' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'%3E%3Cstyle%3E.spinner_V8m1%7Btransform-origin:center;animation:spinner_zKoa 2s linear infinite%7D.spinner_V8m1 circle%7Bstroke-linecap:round;animation:spinner_YpZS 1.5s ease-out infinite%7D%40keyframes spinner_zKoa%7B100%25%7Btransform:rotate(360deg)%7D%7D%40keyframes spinner_YpZS%7B0%25%7Bstroke-dasharray:0 150;stroke-dashoffset:0%7D47.5%25%7Bstroke-dasharray:42 150;stroke-dashoffset:-16%7D95%25%2C100%25%7Bstroke-dasharray:42 150;stroke-dashoffset:-59%7D%7D%3C%2Fstyle%3E%3Cg class='spinner_V8m1'%3E%3Ccircle cx='12' cy='12' r='9.5' fill='none' stroke-width='3'%3E%3C%2Fcircle%3E%3C%2Fg%3E%3C%2Fsvg%3E");width:1rem}`,
    );
  }
  function Ke(e, t, n) {
    const r = e.slice();
    return (r[17] = t[n]), r;
  }
  function Zt(e) {
    let t;
    return {
      c() {
        t = Y('Summarize');
      },
      m(n, r) {
        E(n, t, r);
      },
      d(n) {
        n && x(t);
      },
    };
  }
  function jt(e) {
    let t, n;
    return {
      c() {
        (t = k('span')),
          (n = Y(`
    Summarizing`)),
          m(t, 'class', 'loading-icon svelte-153y05y');
      },
      m(r, o) {
        E(r, t, o), E(r, n, o);
      },
      d(r) {
        r && (x(t), x(n));
      },
    };
  }
  function Ve(e) {
    let t, n, r;
    function o(s) {
      e[12](s);
    }
    let a = { $$slots: { footer: [Vt], default: [Kt] }, $$scope: { ctx: e } };
    return (
      e[2] !== void 0 && (a.showModal = e[2]),
      (t = new Tt({ props: a })),
      J.push(() => Oe(t, 'showModal', o)),
      t.$on('close', e[9]),
      {
        c() {
          we(t.$$.fragment);
        },
        m(s, i) {
          le(t, s, i), (r = !0);
        },
        p(s, i) {
          const l = {};
          i & 1048603 && (l.$$scope = { dirty: i, ctx: s }),
            !n && i & 4 && ((n = !0), (l.showModal = s[2]), Le(() => (n = !1))),
            t.$set(l);
        },
        i(s) {
          r || (y(t.$$.fragment, s), (r = !0));
        },
        o(s) {
          A(t.$$.fragment, s), (r = !1);
        },
        d(s) {
          ae(t, s);
        },
      }
    );
  }
  function qe(e) {
    let t,
      n,
      r = Fe(e[4]),
      o = [];
    for (let s = 0; s < r.length; s += 1) o[s] = Qe(Ke(e, r, s));
    const a = (s) =>
      A(o[s], 1, 1, () => {
        o[s] = null;
      });
    return {
      c() {
        for (let s = 0; s < o.length; s += 1) o[s].c();
        t = re();
      },
      m(s, i) {
        for (let l = 0; l < o.length; l += 1) o[l] && o[l].m(s, i);
        E(s, t, i), (n = !0);
      },
      p(s, i) {
        if (i & 17) {
          r = Fe(s[4]);
          let l;
          for (l = 0; l < r.length; l += 1) {
            const c = Ke(s, r, l);
            o[l]
              ? (o[l].p(c, i), y(o[l], 1))
              : ((o[l] = Qe(c)), o[l].c(), y(o[l], 1), o[l].m(t.parentNode, t));
          }
          for (se(), l = r.length; l < o.length; l += 1) a(l);
          ie();
        }
      },
      i(s) {
        if (!n) {
          for (let i = 0; i < r.length; i += 1) y(o[i]);
          n = !0;
        }
      },
      o(s) {
        o = o.filter(Boolean);
        for (let i = 0; i < o.length; i += 1) A(o[i]);
        n = !1;
      },
      d(s) {
        s && x(t), it(o, s);
      },
    };
  }
  function Qe(e) {
    let t, n;
    return (
      (t = new Lt({ props: { service: e[17], pageId: e[0].page_id } })),
      {
        c() {
          we(t.$$.fragment);
        },
        m(r, o) {
          le(t, r, o), (n = !0);
        },
        p(r, o) {
          const a = {};
          o & 16 && (a.service = r[17]), o & 1 && (a.pageId = r[0].page_id), t.$set(a);
        },
        i(r) {
          n || (y(t.$$.fragment, r), (n = !0));
        },
        o(r) {
          A(t.$$.fragment, r), (n = !1);
        },
        d(r) {
          ae(t, r);
        },
      }
    );
  }
  function Kt(e) {
    let t,
      n = je(e[3]) + '',
      r,
      o,
      a,
      s = e[1].features.suggestion === !0 && e[4].length > 0 && qe(e);
    return {
      c() {
        (t = new pt(!1)), (r = N()), s && s.c(), (o = re()), (t.a = r);
      },
      m(i, l) {
        t.m(n, i, l), E(i, r, l), s && s.m(i, l), E(i, o, l), (a = !0);
      },
      p(i, l) {
        (!a || l & 8) && n !== (n = je(i[3]) + '') && t.p(n),
          i[1].features.suggestion === !0 && i[4].length > 0
            ? s
              ? (s.p(i, l), l & 18 && y(s, 1))
              : ((s = qe(i)), s.c(), y(s, 1), s.m(o.parentNode, o))
            : s &&
              (se(),
              A(s, 1, 1, () => {
                s = null;
              }),
              ie());
      },
      i(i) {
        a || (y(s), (a = !0));
      },
      o(i) {
        A(s), (a = !1);
      },
      d(i) {
        i && (t.d(), x(r), x(o)), s && s.d(i);
      },
    };
  }
  function Ye(e) {
    let t, n, r;
    function o(s) {
      e[11](s);
    }
    let a = {};
    return (
      e[0] !== void 0 && (a.article = e[0]),
      (t = new Rt({ props: a })),
      J.push(() => Oe(t, 'article', o)),
      {
        c() {
          we(t.$$.fragment);
        },
        m(s, i) {
          le(t, s, i), (r = !0);
        },
        p(s, i) {
          const l = {};
          !n && i & 1 && ((n = !0), (l.article = s[0]), Le(() => (n = !1))), t.$set(l);
        },
        i(s) {
          r || (y(t.$$.fragment, s), (r = !0));
        },
        o(s) {
          A(t.$$.fragment, s), (r = !1);
        },
        d(s) {
          ae(t, s);
        },
      }
    );
  }
  function Vt(e) {
    let t,
      n,
      r = e[1].features.subscription === !0 && Ye(e);
    return {
      c() {
        r && r.c(), (t = re());
      },
      m(o, a) {
        r && r.m(o, a), E(o, t, a), (n = !0);
      },
      p(o, a) {
        o[1].features.subscription === !0
          ? r
            ? (r.p(o, a), a & 2 && y(r, 1))
            : ((r = Ye(o)), r.c(), y(r, 1), r.m(t.parentNode, t))
          : r &&
            (se(),
            A(r, 1, 1, () => {
              r = null;
            }),
            ie());
      },
      i(o) {
        n || (y(r), (n = !0));
      },
      o(o) {
        A(r), (n = !1);
      },
      d(o) {
        o && x(t), r && r.d(o);
      },
    };
  }
  function qt(e) {
    let t, n, r, o, a, s, i, l;
    function c(f, d) {
      return f[5] ? jt : Zt;
    }
    let b = c(e),
      p = b(e),
      u = e[6] && Ve(e);
    return {
      c() {
        (t = k('link')),
          (n = N()),
          (r = k('button')),
          p.c(),
          (o = N()),
          u && u.c(),
          (a = re()),
          m(t, 'href', 'https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap'),
          m(t, 'rel', 'stylesheet'),
          m(r, 'class', 'getsummer-btn svelte-153y05y'),
          $e(r, 'opacity', e[7].opacity);
      },
      m(f, d) {
        w(document.head, t),
          E(f, n, d),
          E(f, r, d),
          p.m(r, null),
          E(f, o, d),
          u && u.m(f, d),
          E(f, a, d),
          (s = !0),
          i || ((l = L(r, 'click', e[8])), (i = !0));
      },
      p(f, [d]) {
        b !== (b = c(f)) && (p.d(1), (p = b(f)), p && (p.c(), p.m(r, null))),
          (!s || d & 128) && $e(r, 'opacity', f[7].opacity),
          f[6]
            ? u
              ? (u.p(f, d), d & 64 && y(u, 1))
              : ((u = Ve(f)), u.c(), y(u, 1), u.m(a.parentNode, a))
            : u &&
              (se(),
              A(u, 1, 1, () => {
                u = null;
              }),
              ie());
      },
      i(f) {
        s || (y(u), (s = !0));
      },
      o(f) {
        A(u), (s = !1);
      },
      d(f) {
        f && (x(n), x(r), x(o), x(a)), x(t), p.d(), u && u.d(f), (i = !1), l();
      },
    };
  }
  function Qt() {
    return { opacity: 0 };
  }
  function Yt(e, t, n) {
    let r = !1,
      { projectId: o } = t,
      { settings: a } = t,
      { article: s } = t,
      i = '',
      l = [],
      c = !1,
      b = !1,
      p = !1,
      u = Qt();
    const f = ke(o);
    ht(async () => {
      p || (n(7, (u = { opacity: 1 })), n(6, (p = !0)));
    });
    const d = (h = 100) => {
        setTimeout(() => {
          n(2, (r = !0)), n(7, (u.opacity = 0), u);
        }, h);
      },
      g = () => {
        if (!b) {
          if (i) return d();
          n(5, (b = !0)), (c = !1);
          try {
            const h = f.getSummary(s.page_id);
            h.result.subscribe((M) => {
              n(3, (i += M));
            }),
              h.isCompleted.subscribe((M) => {
                M === !0 && ((c = !0), T());
              }),
              d(100);
          } catch {
            n(5, (b = !1));
          }
        }
      },
      T = async () => {
        var h;
        if (c)
          try {
            const M = await f.getServices(s.page_id);
            (h = M.body) != null && h.hasOwnProperty('services') && n(4, (l = M.body.services));
          } catch (M) {
            console.log(M);
          }
      },
      ye = () => {
        n(5, (b = !1)), n(2, (r = !1)), setTimeout(() => n(7, (u.opacity = 1), u), 500);
      };
    function xe(h) {
      (s = h), n(0, s);
    }
    function C(h) {
      (r = h), n(2, r);
    }
    return (
      (e.$$set = (h) => {
        'projectId' in h && n(10, (o = h.projectId)),
          'settings' in h && n(1, (a = h.settings)),
          'article' in h && n(0, (s = h.article));
      }),
      [s, a, r, i, l, b, p, u, g, ye, o, xe, C]
    );
  }
  class Ut extends ue {
    constructor(t) {
      super(), ce(this, t, Yt, qt, Q, { projectId: 10, settings: 1, article: 0 }, Ht);
    }
  }
  let X, Ue, Ge;
  const Je = (e) => {
      console.log(`%c${e}`, 'background: #FFEFE7; padding: 2px 10px;');
    },
    We = () => {
      X && typeof X.$destroy == 'function' && X.$destroy(), (X = void 0);
    },
    Gt = (e, t, n) => {
      var a;
      const r = 'getsummer-' + e;
      let o = document.getElementById(r);
      return (
        o
          ? (o.innerHTML !== '' && (o.innerHTML = ''),
            (a = o.shadowRoot) != null && a.innerHTML && (o.shadowRoot.innerHTML = ''))
          : ((o = document.createElement('div')), (o.id = r), document.body.appendChild(o)),
        We(),
        (X = new Ut({
          target: o.attachShadow({ mode: 'open' }),
          props: { projectId: e, settings: t, article: n },
        })),
        r
      );
    },
    Xe = (e, t, n = 100) => {
      const r = new URL(t).pathname,
        o = e.settings;
      clearInterval(Ue),
        clearTimeout(Ge),
        !(typeof o.paths.find((s) => r.indexOf(s) === 0) > 'u') &&
          (Ge = setTimeout(() => {
            xt(e.id, t)
              .then((s) => {
                const i = s.body;
                if (!i) return Je("GetSummer: Skipping page as there's no article");
                if ('code' in i) return console.error('GetSummer', s);
                const l = () => Gt(e.id, o, i.article),
                  c = l();
                Ue = setInterval(() => {
                  document.getElementById(c) === null &&
                    (Je('GetSummer: App destroyed, reinstalling'), We(), l());
                }, 2e3);
              })
              .catch((s) => {
                console.error('GetSummer Init App', s);
              });
          }, n));
    },
    et = { id: window.GetSummer.id, settings: window.GetSummer.settings };
  let pe = location.href;
  Xe(et, pe),
    new MutationObserver(function () {
      location.href !== pe && ((pe = location.href), Xe(et, pe, 1e3));
    }).observe(document, { subtree: !0, childList: !0 });
});
