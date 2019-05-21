---
layout: post
title:  'Capitalism in the open-source world'
date:   2019-04-19 17:16:38 +0200
---

Last modified: 2019-05-21 12:38

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

However, to play the devil's advocate against my own arguments, I have at least one good example of a rebuilt package:<br>
[Swiftmailer](https://swiftmailer.symfony.com/).<br>
The package uses so many old and bad practices that even if it works well, its "design flaws" prevent some new usages of what a "mailer" lib should have (async, only HTTP calls instead of SMTP, better and easier API and configuration, etc.).

These are the reasons why it is completely rewritten into [Symfony Mailer](https://github.com/symfony/mailer).
There is no migration path because the change is so big that there can be no clean migration path, at least not without many years of wait and maintenance.
To me, rewriting Swiftmailer from scratch was a perfect solution. And since the maintainers of Swiftmailer and Symfony Mailer are the same, there's no competition at all: same feature but "better", but same people, and entirely new things. Symfony Mailer is not Swiftmailer. It is something new.

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

As a nice example related to Flysystem's bundle, the only new feature in the new bundle is something that took me one single hour of work & tests & checks and I submitted them [in this PR](https://github.com/1up-lab/OneupFlysystemBundle/pull/190), and it was accepted. One hour, and everyone gets the "very shinier feature, such wow" that is promoted elsewhere.

There is no real argument in here, only things that could probably have cost way less by just helping the original package.

### "Follows standards of Symfony and Flysystem communities."

What standards? K&R vs Allman indentation style? Rich models versus anemic models? Mediator over Observer?

Some organizations have very strict coding styles, such as [Doctrine](https://github.com/doctrine/coding-standard), and [Symfony](https://symfony.com/doc/current/contributing/code/standards.html) too.

Yet if some styles differ, most of the time it is a matter of taste, an "implementation detail". If the code acts well, is performant enough (benchamarks & profiling proving it) and features are flexible, what "standards" would you expect more? 
You could use tools like [PHPStan](https://phpstan.org/) or [Psalm](https://psalm.dev/docs/installation/) to have stronger coding standards.

Standards are things you _can_ follow if some problems occur in the organization process. If you're a library, standards will not be used the same way as if you are a triple-A framework, because the impact is not the same.

But again, if you want to follow a standard, I don't think the maintainers from 1up-lab would have refused something "closer to Symfony standards" while being a Symfony bundle. 

After all, [they are working on CS fixes](https://github.com/1up-lab/OneupFlysystemBundle/pull/191), and anybody could discuss. And by the way, the original author of the new FlysystemBundle [never opened any issue to discuss with the community](https://github.com/1up-lab/OneupFlysystemBundle/issues?utf8=%E2%9C%93&q=author%3Atgalopin) about a new integration with new standards and stuff. Click the link: never.

A feature is only a pull-request away.

All of these statements could be true for this Flysystem bundle, and more important: they could be true for ANY package, actually.

## It is not just about "a library", it goes way abroad

I'm ranting about this because of a bigger problem.

You shouldn't be surprised if I tell you that we are in a society of consumerism ruled by capitalism.

Consume something, if you don't like it, go elsewhere, or do your own. And you **pay** for that. All the time.

### The "past"

The "do your own" was nice when "things" were not as advanced as today.

Workers are being replaced by machines in factories for a good reason: it makes more "things" for less money and allows the boss to earn more money. This makes the worker go home or find another job.

In the IT industry, like, 20-30 years ago, it was mostly about "do it yourself" because there was almost no documentation, no standard, and programming languages were a bit more cryptic than today. I remember my older brother reading a 200+ pages book in A4 format, filled with lines of code to copy on his own computer, just to code a simple game.

Today it is about elitism.

Workers are replaced by automated machines, and low-level developers are "replaced" with high-level programming interfaces. The problem is that the IT industry needs so many developers that we need to coach, train and educate, and many training centers claim to rise new developers in like 3-6 months. This is wrong, you don't make a developer in 6 months, at best you can make a nice junior developer, but not "a developer". All the missing experience and state of mind cannot be acquired in such a rush. Therefore, developers entering this industry are less skilled than the "old" ones. This makes sense, it is logical. But.

What we experience is that older developers (the one with, let's say, more than 10 years of experience, a degree in computer science, or just a true passion and full-time + free time dedicated to programming) are so much more experienced than new developers, the gap is so big, that we can experience something like a "conflict of generation". This is also "normal" but it should not lead to issues such as [elitism on StackOverflow](https://stackoverflow.blog/2018/04/26/stack-overflow-isnt-very-welcoming-its-time-for-that-to-change/).

### The "now"

Well, elitism is everywhere now.

Workers disappear, and high-skills jobs come upfront. But everybody needs these top-level jobs. But it's hard to find top-level candidates. Like the current airline pilot shortage, or the programmers shortage.

We need "high skills" everywhere, and lesser amount of skills is not really acceptable, because stacks continue to become more and more complex (docker, kubernetes, async, APIs, micro-services, etc.). In the past we had the "integrator", "sysadmin", "dev", "UX designer". Now we have _"devops that do everything because it's so cool to have a full-stack-ninja-jedi-that-plays-foosball-in-the-office-and-drinks-beer-and-eats-pizza"_ or anything that people tend to write in their job offers just because they struggle while searching for developers. 

Let me repeat this:

Jobs that need less skills are disappearing.

This forces people with less skills to either struggle in the job market, or train themselves for a more elitist job. And this is not right, because I do not believe anyone can become a developer. At least, I think that not everyone can become an advanced developer. And our industry will suffer this in the next years, because it needs developers with good skills. Poor skills and projects go wrong, to say the least. Developers get sad, they leave after 1-3 years, and start over in another company. Until they eventually find a "better place".

These companies consume developers as we use to consume "things".

## Let's come back to the subject 

FOSS is about consuming free software. Free. So we can do whatever we want with it.

But the best of FOSS is the **spirit of sharing**. You share, you discuss, debate, contribute, benefit and so on.

Sharing is not something that is really considered as a main value in the world of capitalism.

The values in capitalism are things that bring more profit.

FOSS's profit is not financial profit, it's more about sharing tools that are useful for people. It's more a **communautary profit**. 

In its roots, **free open-source software is humanism**.

But not only. At least, this is what I fear:

### Ego

[We're only human, after all](https://www.youtube.com/watch?v=L3wKzyIN1yk).

But I feel like sometimes (more like "often", yeah, this post is subjective), ego predomines all.

As said above, with FOSS there are two strategies: refactor, or recreate.

Capitalism would say "recreate and sell". Of course, FOSS can't sell that much. So we end up with ego, the main source of men's satisfaction.

(I'm talking about men and not women because I feel like women are not really that much into ego especially in the FOSS world, mostly because IT is unfortunately 95% men and women are a minority, and most of them suffer because of this situation, but that's not the subject.)

A man's satisfaction can come in many shapes, but in softwares industry, ego comes with how much you're considered an "authority" in your field of expertise.

A simple example: become a Symfony developer, get skills with it, contribute to the Symfony framework with one or two features, and you can be considered by many as a form of "authority". Some few advanced skills and you can trigger other devs' impostor syndrome.

Theoretically, anyone could contribute to such framework. That's what some core team members say in their conferences, for example, and they're right in many subjects: follow the guide, ask for help, and anyone could contribute.

Yes, but no.

Not everyone is involved in open-source as much as the Symfony core team or other contributors. Some people are passionate about the subject, and some other just don't care as long as they can get their wage. I know my older brother who's also in IT is not really interested as long as he can still do his job 8 hours a day and come back home and just don't care about it. That's fine, he's just out of the FOSS world, but he can still be a good developer (he's an architect actually, but he's also a developer, well).

Many devs are in the _grey zone_, meaning they are interested in open-source but they don't contribute nor participate very much, mostly because they don't find time.

And I'm saying _"They don't find time"_. Most of the time, we **can** find time to work on an open-source project, but many devs will never do it at work because their boss disagrees (and I wish their boss could agree), or because they don't want to go back to code after they finish their job (or they can't, if they have family and kids, or already have other hobbies). Sometimes they're afraid to contribute, too.

So there's basic elitism in saying things like _"If you don't like it, do your own"_, because **not everyone can**.

### Not everyone can, hence a paradox

It is the main paradox in FOSS to me:

* You share free tools for good and for the community
* Anyone can do whatever they like (in the limits of the license)
* If they do want to contribute, you'll discuss and hopefully end up with a consensus and improve your library for the good and the community
* But if this "anyone" does not suit your personal feelings about how to contribute, you just let them f*ck off.

And the last point is the most important, because it can even be triggered _before_ any contribution.

You don't like the person who made a very popular package? Let's fork it and promote your own work. Ego fight.

Some maintainer doesn't like your idea, or worse, doesn't like you? They'll just remove your contribution, do it themselves and promote their work. 

If you say "competition is nice" you are totally in to capitalism.

Competition is interesting when there are benefits on both (or more) sides of the competition.

For example, Laravel vs Symfony is a nice competition because they have a totally different philosophy, and both can benefit from the other in order to bring new features. For example, Laravel borrows tons of things from Symfony by using its components, and Symfony introduced a few features from Laravel in the past (like the `dd()` function, or testing assertions inspired by Laravel Dusk). This is a sane competition, when looking at these frameworks at least (it becomes less sane when looking at human beings...).

A competition between Package A and B, one being the fork or a rewrite of another, is not really sane, because you end up with 2 packages doing the exact same thing, and only popularity will win. Nobody ever created a fork of Twig in order to "optimize" it. No. Twig was just optimized. And rewritten a bit, maybe.

Here, I'm talking about a concept: a package that does the same thing than its competitor, but is claimed to "be better".

To me it is pure ego to just rewrite the original package and claim the new one is "better" without having contributed to the first one, and did not even started discussing.

This is not free open-source software.<br>
This is ego.<br>
This is capitalism.
