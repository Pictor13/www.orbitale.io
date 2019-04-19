---
layout: post
title:  'Capitalism in the open-source world'
date:   2019-04-19 17:16:38 +0200
---

A good representation of how the capitalism spirit can be introduced in FOSS:
 
**Reinvent the wheel, but "better".**

I thought it was only a problem in the Javascript world (Hence the tons of packages that do the same thing. Have you ever searched for [uglify on npm](https://www.npmjs.com/search?q=uglify)?), but it is also slowly coming in PHP too.

> Don't tell me _"It's open-source, we do whatever we want"_, or _"Just don't use it if you don't like it"_. The point of this post is precisely elsewhere. Just read to the bottom.

# The (totally subjective) state of FOSS

When a package is widely used by many people, sometimes people complain that it's "bad".
Why is it bad? You have 4 hours (or years) of debate to discuss. But the point is: **everybody have arguments to improve something**.
FOSS is about this engagement, sometimes.

> Small reminder for those who don't know: FOSS means Free Open Source Software

An example which is not much applicable: frameworks.

For example: the endless debate "Symfony vs Laravel". It is pointless because most of the arguments are subjective and depend on whatever people think of "how to do programming". And the impact is too large.

No, it's applicable to LIBRARIES.

A library is something that should be "reusable across the whole ecosystem". Could it be a C library, a Javascript module, a Ruby gem or a PHP package (or PHP extension).
Therefore, after a long time, some libraries become popular. Even across many frameworks.

This is the case for some: [League/Flysystem](https://github.com/thephpleague/flysystem ), which is very popular (alongside with [Gaufrette](https://github.com/KnpLabs/Gaufrette) but it is much less popular), also [HTMLPurifier](http://htmlpurifier.org/), and so on.

These packages have a long lifespan and they're all good, it's just that they're old, and debug or maintenance can be tricky.

So, what to do?

Well, two solutions:

1. Rebuild something new
2. Refactor it

## Rebuild something new

Solution 1 seams easier:

> « Hey, this package is old, I made a new one, it does the same thing, but it is prettier! »

We may think it's interesting, and here are a few reasons why:

* Clean code first, yeah. Can be a really nice strategy because you completely drop what is old and bad, and get a fresh codebase, new documentation. Depending on who does this, you may have a totally new package with a new team or maintainers (or just one maintainer), and have a different opinion of "good code".
Some people would say "competing is nice".
* You can also drop old features that become unused, especially if the language has drastically evolved.
* You can focus on "new practices". If the language allows strict type, you can strict type everything. If it allows OOP, you can use objects everywhere instead of plain global functions. Benefits from autoloading if it wasn't available
before, etc.

Some disadvantages though:

* Of course, you probably end up with either "copy/paste old code and adapt/review" or "recode from scratch", which can take longer (let's say, _a year_).
* If it's a new package, you won't have the same "adoption" and many people won't migrate because of the cost of migration, because they don't like it, or because of the next point:
* It won't be as battle-tested as the popular one, so you will likely have a big maintenance to do, and will need much time to implement new features because of the lack of community.

There are also more reasons why I think it is a bad idea. I talk about this below (did I say that this post is subjective?).

## Refactor it

A solution that kind of "reverses" the problem of the "new package" philosophy.

Some packages really benefit this option, such as [Twig](https://twig.symfony.com), and the advantage is that it does not really have many competitors in the PHP world as a templating engine, therefore refactoring it is, like, "mandatory".

But "refactoring" can also be granular, it can also take time.

There's a nice example of discussion about this in a [Symfony PR](https://github.com/symfony/symfony/pull/30672). The subject is mostly about how a migration path could be provided in Symfony 4.* when changing things in the concepts of a "Kernel" in Symfony, and some thoughts are about _"deprecate in Symfony 5 and remove in Symfony 6"_. As a reminder, Symfony 6 will be released in November 2021. It's almost three years from now (when this post is written). And Symfony 5 will be released in November 2019, so seven months from now.

This is what I would call a "clean migration path". Especially when talking about a component as important as HttpKernel.

Refactoring has tons of disadvantages:

* Migration path is the worst. Either you do not take care of it and just release a new major like _"We changed everything, please adapt"_, or you deprecate things in current version, add clean `@trigger_error('Deprecated (...)', E_USER_DEPRECATED);`, make sure you don't break everything when releasing a new minor, and make sure the new major is stable.
* You have to deal with old code. Old, dirty, silly code. Often code you never wrote. Sometimes code you cannot read, code that is messed up everywhere.
* Yeah, saying it again, but OLD CODE! Practices never seen for decades, maybe some kind of HTML nested in PHP nested in a very old CGI script and... No, that's not possible, is it??

Yeah, refactoring is hard work, but:

* You benefit from your current community. And maybe a lot of people that already know the codebase.
* When a new major version is almost ready, it is easier to call the community and ask for beta-testing it. Release a "release candidate" first, and ask a few people to require it & throw it on their already existing CI, and it should do the trick. But of course it only works for people that don't override too much of your package. Else, this point is, well... pointless.
* Your package is popular. New version is better? Well, it will probably become more popular. Good point for you.

## The "yet another new package" philosophy

Something happened today: [a new "FlysystemBundle" was created](https://titouangalopin.com/introducing-the-official-flysystem-bundle/), and it is hosted on the PhpLeague Github organization.

I was told about the "3 advantages" of this package.

It is supposed to be:

1. Official
2. Better code, better support of Symfony 4.2 features
3. Follows standards of Symfony and Flysystem communities.

Yeah, these are good advantages.

But.

An existing bundle have been flying around (pun intended) for a long time now: [OneupFlysystemBundle](https://github.com/1up-lab/OneupFlysystemBundle), created by 1up-lab.
It's a direct implementation of `ThePHPLeague/Flysystem` and it's already shipped with lots of features.

> What you will read will be way more subjective after these words.

The three points above that were told to me as "a good reason", **could all have been solved without a new package**.

### "It is official"

Yes, it is. Okay. Well. Fine.

What does it mean to be "official"?

It means that **the original maintainers of the library will maintain it**, mostly. If I'm wrong, tell me.

Being official is "just a name". It happened in the past that repositories changed hands and the simple notion of "official" is only valid for a certain period of time.

A nice example is the [FOSCKEditorBundle](https://github.com/FriendsOfSymfony/FOSCKEditorBundle). At the beginning, it was just [IvoryCKEditorBundle](https://github.com/egeloen/IvoryCKEditorBundle), and after a common decision in the community, it was transferred to the FriendsOfSymfony organization for better maintenance and better support. No migration path, you just change the package & version and you get the same code. Or use the old version if you don't want to migrate, but, hey, it's really a migration, since it's the same package, is it?

It is also happening right now for [Laminas](https://framework.zend.com/blog/2019-04-17-announcing-laminas.html) which is the continuation of Zend Framework. Okay, for this example we don't have all the details yet, but I hope you got the point at this stage of the blog post.

So, against what am I ranting again?

"Official" is not an argument.

Anyone could propose 1up-lab to keep the maintenance of the project but make it "the official" one. After all, it's the most used of the Flysystem-related bundles, if not the only one, so why not? 1up-lab keeps being the original authors, it's written everywhere in the commit history, in the comments, in the licence, etc.

"Official" would be a potential argument only if 1up-lab would have refused to "be official". Only. At. That. Time.

And even then: it's open-source, so anyone from ThePHPLeague could've forked it and make it official anyway. No harm. That's what a licence is for.

### "Better code, better support of Symfony 4.2 features"

Yes, "better code" you could have just optimized in the original repo.

"Better support (...)" you could have added with a 3 lines of code change in the original repo (okay, it's not 3 lines, but it is certainly way less lines than rewriting everything).

"(...) of Symfony 4.2 features" you could have supported on either an automated way of doing it (detect Symfony version & use feature), or you could also have dropped support for older versions with a new major version (again, Semver FTW).

There is no real argument in here, only things that could probably have cost way less by just helping the original package.

### "Follows standards of Symfony and Flysystem communities."

What standards? K&R vs Allman indentation style? Rich models versus anemic models? Mediator over Observer?

Some organizations have very strict coding styles, such as [Doctrine](https://github.com/doctrine/coding-standard), and [Symfony](https://symfony.com/doc/current/contributing/code/standards.html) too.

Yet if some styles differ, most of the time it is a matter of taste, an "implementation detail". If the code acts well, is performant enough (benchamarks & profiling proving it) and features are flexible, what "standards" would you expect more? 
You could use tools like [PHPStan](https://phpstan.org/) or [Psalm](https://psalm.dev/docs/installation/) to have stronger coding standards.

Standards are things you _can_ follow if some problems occur in the organization process. If you're a library, standards will not be used the same way as if you are a triple-A framework, because the impact is not the same.

But again, if you want to follow a standard, I don't think the maintainers from 1up-lab would have refused something "closer to Symfony standards" while being a Symfony bundle. 

It is only a pull-request away.

All of these statements could be true for this Flysystem bundle, and more important: they could be true for ANY package, actually.

## It is not just about "a library", it goes abroad

