---
layout: post
title:  'How to migrate to Symfony 4.4 / 5.0'
date:   2019-11-26 06:29:17 -0600
---

Symfony `4.4.0` and `5.0.0` are out!

Let's migrate all the things!

Wait, no. Not yet.

This is a small post about what you need to think about when migrating.

## How to migrate?

First, RTFM: [Upgrading a Major Version (e.g. 4.4.0 to 5.0.0)](https://symfony.com/doc/4.4/setup/upgrade_major.html)

The docs are full of cool advices, and you should go there before reading this post.

After that, if you still think my post is important, I'll leave you with some tips.

### What's new in Symfony `5.0`?

There's almost no big difference between `4.4` and `5.0`.

To sum it up:

**A new Symfony major version is the same as the latest minor, apart all removed deprecations.**

This means that `5.0 === (4.4 - deprecations)`.

There's one slight difference with `5.0` though: there are two new *experimental* components: `String` and `Notifier`. As they are marked as experimental, they cannot be added to `4.4` because it's an LTS version.

### Deprecations

Migrating from `4.x` to `4.4` will create TONS of deprecations. You **must** check whether they come from **your code** or **Symfony's code**. It does not have the same impact:

* If deprecations come from **your code**: you don't care. At least *now*. You have time. [`4.4` will be maintained until 2023](https://symfony.com/releases/4.4). There's no hurry.
* If deprecations come from **Symfony**: you don't care either. This means that Symfony uses old features for [Backwards Compatibility](https://symfony.com/doc/4.4/contributing/code/bc.html) but these **are already removed in the next major version**.

### I WANT IT NOW

You don't need to migrate **now** because `x.y.0` versions are often not 100% stable, because there is never enough volunteers to test the `beta` or `RC` versions of the framework that are available a month before the release.

If your app is big and not 100% stable, you can wait a few patches, like `x.y.2` or `x.y.3`.

### `5.0` is the new hype!

Creating a project with `5.0.0` right now is _kinda fine_, but remember that **not all third-party bundles** are compatible with it.

Many (really, many) already made the move, especially the most common ones (like Doctrine ones, for example), but remember that **bundle maintainers are not paid for that job**.

If you want a third-party bundle to be compatible with Symfony 5.0, then contribute and make it so. You'll find it great and rewarding, I promise.

### Flex it all!

It's been [more than 2 years since Flex was released](https://github.com/symfony/flex/releases/tag/v1.0.0), and many people still think it's mandatory to use it.

It's not.

Flex automatizes the config files setup and directory structure, it also brings a parallel downloader when installing Composer packages, and it also makes sure older Symfony versions are not installed, to make sure that if you want Symfony `x.y`, you'll have **every** Symfony dependency with this version.

All of that could be done totally manually. How? Answer: by doing what we've been doing since Symfony 2.0 was released: **read the documentation**, copy/paste default config, add bundles to our Kernel, etc. And that's okay.

## Conclusion

You have time.

Don't break your entire project.

You can do it in a few months, that's okay.

But do it.
