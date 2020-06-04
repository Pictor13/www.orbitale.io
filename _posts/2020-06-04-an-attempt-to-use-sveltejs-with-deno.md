---
layout: post
title:  'An attempt to use SvelteJS with Deno'
date:   2020-06-04 11:20:56 -0500
---

> First, sorry that this post is so disorganized, I did not find enough energy to make a better post architecture.

I definitely would like [Svelte](https://svelte.dev/) to be usable with [Deno](https://deno.land/), so I tried several methods in order for it to work in the past weeks. I'm close to it, but for now it's not perfect. If you know an easier method, please tell me!

I first tried [on this branch](https://github.com/Pierstoval/svelte/commits/deno) to raw-include node.js dependencies and allow building the entire Svelte stack with Deno.

I made a lot of tests and I think these tests were a lot of time lost for nothing.<br>
It took me a while before I realized that this method was impossible: Svelte is tightly coupled to its dependencies (`estree`, `acorn`, and many others), so moving the entire ecosystem to Deno is not even thinkable, at least not today.

After a while, I tried compiling Svelte's compiler as an <abbr title="ECMAScript Module">ESM</abbr>, and it was actually quite easy.

> If you wonder about <abbr title="ECMAScript Module">ESM</abbr>, <abbr title="CommonJS">CJS</abbr>, <abbr title="Asynchronous Module Definition">AMD</abbr>, <abbr title="Universal Module Definition">UMD</abbr> and all these strange acronyms, I suggest you check out [this blog post](https://irian.to/blogs/what-are-cjs-amd-umd-and-esm-in-javascript/) which explains it very well.
> To sum it up quickly here, we want ESM, because it's the best standard, but Node.js is based on CJS.

Svelte is built with [Rollup](https://rollupjs.org), one of the JS bundlers that exist in the Node.js world (alongside with Webpack, the most known one). It already has a nice and clear building configuration, even for people like me that have never heard about Rollup before looking at Svelte's source code.

I find Rollup to be very interesting, maybe even easier to try than Webpack, but experts might give me some arguments to contradict me, I don't know, I'm no expert on this side of the dark JS world.

As Svelte already builds its `runtime` to <abbr title="ECMAScript Module">ESM</abbr> as well as <abbr title="Common JS">CJS</cabbr>, we just need to build the `compiler` to <abbr title="ECMAScript Module">ESM</abbr> in order to use it.

That's why I created a small PR to add this: https://github.com/sveltejs/svelte/pull/4972

I also created a small [proof of concept Project](https://github.com/Pierstoval/svelte_esm) to try out my ideas.

This actually worked very well!

Until... I ran the server.

The code generated with Svelte's compiler is not fully working.

The issue?

Well... [I'm not the only one](https://github.com/sveltejs/svelte/issues/4806). The `svelte/internal` component is necessary, and the compiler considers that it's available to the generated code. Which is not the case.

If you want to use it, you must include `svelte/internal` somewhere and make it available.

For the <abbr title="Server-side rendering">SSR</abbr> version of the generated code, it's working because I added a [dirty fix](https://github.com/Pierstoval/svelte_esm/blob/master/compile.ts#L36-L39):

```js
/*
 /!\ Dirty fix
 */
const JS_SSR = compiledSsr.js.code.replace(
	'"../svelte/internal"',
	'"../svelte/internal/index.mjs"'
);
```

This fix takes the `svelte/internal` import statement and replaces it with `svelte/internal/index.mjs`.

With this change, it works!

At least, the server.

For frontend-side rendering, I still need to find the issue with the compilation process, but maybe I'll find something at some point.
