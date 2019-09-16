---
layout: post
title:  'How I migrated almost all my work to Docker Act I: genesis'
date:   2019-08-26 10:00:00 +0200
---

This post is the first of a series of four posts about how I started to use Docker for all my projects.

I made some tweets a while ago talking about [Docker](https://www.docker.com/), and I must say that I'm a bit afraid that they get lost in an endless timeline.

So here's a small (or not) post about Docker.

If you want to read the others, please refer to this index:

* Act I: Genesis (current)
* [Act II: PHP](/2019/09/02/how-I-migrated-almost-all-my-work-to-docker-act-II-php.html)
* [Act III: Services](/2019/09/09/how-I-migrated-almost-all-my-work-to-docker-act-III-services.html)
* [Act IV: Project](/2019/09/16/how-I-migrated-almost-all-my-work-to-docker-act-IV-compose.html)

## A long time ago, on a computer far far away...

As I have autism, I can understand some complex things, but I have to "practice" them for a long time sometimes. For example, I now know many things about cartography (since I work on an app for this purpose), but it took me years to understand the mathematical concepts underneath this thing that is cartography.

For Docker, it's the same thing.

Between my first "[whalesay](https://docs.docker.com/get-started/)" and my first "real-life" use of Docker, there's a span of 3 years.

3 years, to be "comfortable" with the concept of an image-that-is-like-an-ISO-file-but-is-not-really-like-an-ISO-file and the concept of a container-that-is-like-a-virtual-machine-but-is-not-really-like-a-virtual-machine. 

Now, I'm _dockerizing_ almost all my projects.

## [How did it come to this?](https://open.spotify.com/track/0UMROwhQyAbWWLSnBH0e1L?si=gaj5R4H3TvWCWgIdngNZpQ) 

I was trapped behind my environment.

I was (and still am) mostly using Windows to work, because, well, I like to have the same machine to do everything. Even though people tell me this is not optimized, I could find nice solutions to optimize my environment (use `cmd` but with some plugins, use WSL when necessary, use [Apache & PHP on Windows](/2017/11/11/apache-and-php-fpm-in-windows.html) with multiple versions of PHP, etc.).

This is still not optimized because if I ever lost my machine (which did not happen in 6 years), I would have to restart from scratch, all setup and stuff.

I was pretty satisfied with Apache Lounge + `php-cgi`, actually. And even [Symfony CLI tool](https://symfony.com/cloud/) uses it when serving an app with `symfony serve`, so this is a nice solution.

I even installed multiple NodeJS versions to fit the different projects I work on.

However, reusability becomes difficult in a few cases:

* Use different PHP extensions everytime. For example, `xdebug` is not installed everywhere, but that's not the worse part (because I can still do `-dzend_extension=xdebug.dll` when running a script). The worse part is when you need some extenson for a specific project, and don't need it for another. Testing features that rely or not on PHP extensions can be tricky (`intl`, `mbstring`, `fileinfo`, etc.), and I was quite tired of enabling/disabling extensions manually & restarting server before working on something.
* Multiple PHP versions is nice, but sometimes a project uses a specific PHP 5.5 or 5.6, and this is a bit harder because I can't have hundreds of PHP versions on my machine. With Docker, I just don't care.
* Restarting the web-server or `php-cgi` is boring on Windows. Even if I can do `nssm restart php7.1-cgi` or `nssm restart apache`, it's not as straightforward as `make restart` on a project. Which doesn't need restart as much often as when working on multiple projects.
* Databases. Most of my projects use MySQL or MariaDB, and I have to have both on my machine. Conflicting ports, root password, etc., things that nobody wants to take care of. I just want a f*** database ☺. And by the way, installing MySQL on Windows is a [PITA](https://www.urbandictionary.com/define.php?term=pita#549368).
* External components: Redis, ElasticSearch, Blackfire (installing Blackfire for **all** versions of PHP, phew…), RabbitMQ, and tons of other tools that anybody may need during development. I was lazy so most of the time I configured "nothing in dev, redis in prod". Bad idea. Have redis in prod? Then, have redis in dev. Period, end of story. But which version? Well, each project has its own. Again here, one single environment is not the best option.

I could find more cases, but at least these ones might help understanding why "native tools" is not always a good idea when working on multiple projects…

## But... why? Should we seriously do that?

Why would we dockerize everything?

I will say it right now: there are **tons of good reasons not to dockerize your environment**.

For example, on my personal machine, I still install latest PHP with a few extensions (apcu, mysql, pgsql, etc.), and I use it conjointedly with Symfony CLI, this way I don't have to install any web server. That's for PHP.

I also usually install latest NodeJS and latest Ruby versions, so I can easily maintain some legacy projects, or this blog with Ruby. I also use NodeJS as a small web-server wrapper when I have fun with [p5.js](https://p5js.org/) or [TypeScript](https://www.typescriptlang.org/) every once in a while.

Another good reason to not use Docker: sometimes, things are quicker with `apt-get install ...`. Like PHP, because it's straightforward to set up. And if you need a specific version of PHP, you can rely on [deb.sury.org](https://deb.sury.org/) for an `apt` repository allowing you to install latest PHP versions & other ones if you need.

> **Note:** Sury's repo is good for latest versions but it also can be a drawback in the end: it only provides the latest versions of PHP, not the old ones (like PHP5 or specific versions like 7.2.3). The version choice is therefore limited. (Thanks [Wouter](https://github.com/wouterj) for the reminder)

Finally, the best reason is difficulty: you need to actually _learn_ Docker concepts, how it works, all the edge cases (networks, volumes...), and even worse: you need to build images. Trust me, building "the" image that "just works" takes time and energy, and I got lost in the past four days just because I forgot to add a system dependency or because I ran a script before another...<br>
If you have mentors that can help you fix your Docker issues, or if you have a lot of time, Docker is a really nice way to go. But time is money, and the boss doesn't care, he just wants you to ship, even if you do it badly, so it's better to stick to something you already know an "just works" (and I personally do not like that at all, but I'm not the boss yet, so I have no way to fix this for now).

Docker is mostly for complex or legacy projects with very specific dependencies and probably tons of other services (mail, queue...), and for people that have **the best compromise with time, knowledge and learning practices**.

## Dockerize all the things!

In my next post, I will show some examples on how we can start a graceful _"dockerization"_ of our environment.

**Important note:** I will **not** make an _introduction to Docker concepts_. For this, there's an awesome [Get started with Docker](https://docs.docker.com/get-started/) that I followed a long time ago and re-read from time to time to see if I forgot something, or to keep up to date with the basics.
In the next posts, I will assume you know the basics of how to build custom images, and even use Docker Compose.

But don't worry, it'll be gentle! I just want to make it straightforward, and the examples will be as easy to understand as possible.

See you on next post! 
