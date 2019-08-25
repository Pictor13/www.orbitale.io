---
layout: post
title:  'How I migrated almost all my work to Docker Act II: PHP'
date:   2019-09-02 10:00:00 +0100
---

This post is the second of a series of three posts about how I started to used Docker for all my projects.

If you have not read the other ones, you may give them a go before reading this one:

* [Act I](/2019/08/26/how-I-migrated-almost-all-my-work-to-docker-act-I-genesis.html)
* Act II (current)
* [Act III](/2019/09/09/how-I-migrated-almost-all-my-work-to-docker-act-III-services.html)
* [Act IV](/2019/09/16/how-I-migrated-almost-all-my-work-to-docker-act-IV-compose.html)

## Reminder of previous post

In the previous post, I said that having a "native" environment can be faster in terms of performances and handiness, but cumbersome when handling updates, legacy or multiple projects.

This second post will explain how we can use Docker with our favourite programming language (even though this post is PHP-oriented).

## PHP: State of the art

Let's talk about PHP as a web server.

This is not a secret: PHP's native web server introduced in PHP 5.4 is not the best.

[Fabien Potencier](https://speakerdeck.com/fabpot/symfony-local-web-server-dot-dot-dot-reloaded) started a poll to ask what web server people tend to use, and if we exclude Docker (which is the subject of this series of posts) and `php bin/console server:start` with Symfony (which is focused on Symfony), the most used solutions are native Nginx or native Apache servers.

This means that with PHP we **need** a web server. And a good one.

The Symfony CLI partly solved this issue: a Go-based web server running in the background, proxying requests to your `php-fpm` or `php-cgi` or `php -S` server (in this order of preference) depending on their availability (it can also provide HTTPS and other cool features).

However, this still needs a PHP version installed.

> **Note:** If you don't use PHP at all, imagine the same kind of workflow for your favourite language, could it be Ruby, Python, Javascript, or another. After all, they all have language & system dependencies, so the behavior could be really similar.

Dockerizing PHP is so big that I'll make another post for _other_ services than PHP.

## PHP: how to?

> Q: What is PHP?
> A: It is an interpreted language (for short)
> Q: How do we run it?
> A: Compile PHP or download an already-compiled version for your OS, and (... blah blah)

PHP is mostly run in two different manners: command-line, and web-server.

> **Note:** Actually, there can be tons of different other manners to run PHP. According to the [non-exhaustive list of SAPIs in PHP documentation](https://www.php.net/manual/en/function.php-sapi-name.php), there are at least 23 known SAPIs.
> The most common ones are probably `cli`, `fpm-fcgi`, `apache` and `cli-server`, which corresponds to command-line and web-server SAPIs.

For each solution, there's an associated [official Docker image for PHP](https://hub.docker.com/_/php) that you can use.

The ones I recommend are the following: `php:7.3-fpm` if you need it as a web-server, and `php:7.3-cli` if you only need the CLI.

Of course, here I'm talking about `7.3`, but in a few months, I'll update this post and recommend `7.4` after its stable release.

Checkout [all tags](https://hub.docker.com/_/php?tab=tags) if you need to know what versions you can install. You can even find older PHP versions, like 5.4 or 5.3, for legacy projects!

They are based on Debian and are pretty much safe. Some people prefer Alpine, but I don't like it: even if it's lightweight, it's not using the same C compiler and to me it doesn't have the same stability.

Other tags (like `-apache` or `-stretch` suffixes) are mostly when you need to use PHP with a legacy project, and to replicate an old behavior.

**For new projects, I recommend to use the `fpm` version anyway, so you're safe**.

## Don't _use_ PHP! Rebuilt it!

I don't mean to _recompile_ it, but it's almost the same thing.

I recommend to **always** use a custom Dockerfile to **build your own PHP version for your project**.

PHP is not usually meant to be "global" when working with multiple projects. Even when working with one single project.

If you still want "your" PHP version to be "global", you could still create a "PHP Docker base" project and store the config there, because we'll be building a Docker image anyway, and we can use it anytime and anywhere. Here, it's up to you.<br>
I'll personally consider that PHP will be a per-project one, but you can do otherwise if you like.

It almost always start with something like this:

```
# Directory structure:
MyProject/
├─── docker/                         <-- Where to store the config for all your Docker images
│    └─── php/
│         ├─── bin/                  <-- Sometimes we can have executables/helpers
│         │    └─── entrypoint.sh    <-- I'll talk about this later, don't worry :)
│         └─── etc/
│              └─── php.ini          <-- And indeed, every PHP project has its own PHP configuration
└─── Dockerfile
```

```dockerfile
# ./Dockerfile
FROM php:7.3-fpm

LABEL maintainer="pierstoval@gmail.com"

## Not mandatory, but I use it as a convention, it's easier to set it up for any other project
WORKDIR /srv

## Having it named as "99-..." makes sure your file is the last one to be loaded,
## therefore helping you override any part of PHP's native config.
COPY docker/php/etc/php.ini /usr/local/etc/php/conf.d/99-custom.ini
```

```ini
; docker/php/etc/php.ini
; This config file contains default config for development.
; Feel free to add/update it with whatever you need.
allow_url_include = off
date.timezone = Europe/Paris
max_execution_time = 180
memory_limit = 1024M
phar.readonly = off
post_max_size = 100M
realpath_cache_size = 4M
realpath_cache_ttl = 3600
short_open_tag = off
upload_max_filesize = 100M

[errors]
display_errors = On
display_startup_errors = off
error_reporting = E_ALL

[opcache]
opcache.enable = 1
opcache.enable_cli = 1
opcache.max_accelerated_files = 50000
```

In my next post, I will talk about other services: database, cache, mail...

This is the **base**.

## Base non-PHP dependencies

As it's Debian-based, we also need **to update system dependencies**, and prepare the path for adding other dependencies, sometimes mandatory!<br>
To do so, I add this to the Dockerfile:

```dockerfile
RUN set -xe \
    && apt-get update \
    && apt-get upgrade -y \
    \
    && `# Libs that are needed and  will be REMOVED in the final image` \
    && export BUILD_LIBS=" \
    " \
    && `# Libs that need to be installed for some dependencies (mostly PHP ones) but that will be KEPT in the final image` \
    && export PERSISTENT_LIBS=" \
    " \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        make \
        curl \
        git \
        unzip \
        $BUILD_LIBS \
        $PERSISTENT_LIBS \
    \
```

Let's sum up what we have here:

* You can note that all of this is a **one-line** `RUN` statement. It makes Docker images lighter.
* You may also note that I'm abusing `\` and "useless" comments, but this is important to me to **document the Dockerfile**. I've seen too many Dockerfiles without any explanation on why a dependency is added etc., so that's why I'm doing this.
* Also, you may note the difference between `BUILD_LIBS` and `PERSISTENT_LIBS`.<br>
Sometimes when installing dependencies, you need the whole lib, but when it's installed, you just need the headers (most of the time, it's the package name ending with `-dev`). To make the image lighter, we differentiate both.
* Also, there are reasons why I add `make`, `curl`, `git` and `unzip` by default: it makes dependencies installation easier, Composer may use it to install dependencies, and when you needs to debug the whole image/running container, it's also faster. But these are not 100% mandatory (and some packages you will install in the future may require and install them anyway).<br>
You could add them to `BUILD_LIBS` to make your image lighter after building it

That's it for _system_ dependencies, but that's not finished.

## User permissions

Docker has a strange way to manage user permissions: by default, it's `root`.

The problem with `root` is that it will cascade to your filesystem. Therefore, any file created in a directory that is shared between the container and your filesystem will belong to `root`.

That's why we need a workaround to make sure the user in the container is the same as the user _running_ the container (your machine user).

> **Note:** On Windows, this issue is not happening at all, because Windows does not use the same permission system as Linux.
> Be careful: every Docker image you create **must** be tested on Linux, as it's probably going to be used on Linux anytime.
> Without this workaround, your image will work on Windows but not on Linux.
>
> Also note that this workaround will have to be repeated for **every** Docker image that **manipulates your filesystem**. Images that don't touch your filesystem don't need this.

### Gosu

I'm using [tianon/gosu](https://github.com/tianon/gosu), it uses features like setuid, setgid, etc., in order to "mock" the final Unix user based on another user (the one executing the container, in our case).

Here's what I add to the Dockerfile:

```dockerfile
# ... the "RUN" Docker statement
    && `# User management for entrypoint` \
    && curl -L -s -o /bin/gosu https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }') \
    && chmod +x /bin/gosu \
    && groupadd _www \
    && adduser --home=/home --shell=/bin/bash --ingroup=_www --disabled-password --quiet --gecos "" --force-badname _www \
    \
```

And after that, I add a `_www` user and group, and I need to remember the name, because I will reuse it later.

This is not finished, but this is the base for better user permissions.

Next is...

### The Entrypoint

If you know a few "advanced" things about Docker, you probably know that a Docker image has two parameters to run it: the entrypoint and the command.

* The command is something like `php -S 127.0.0.1:8080`. It's the final command that's executed by the container. It's not mandatory and can be easily overriden, for example when you want to run a shell in a container based on your image. This means we could replace the command with `bash` to run a [Bourne again shell](https://en.wikipedia.org/wiki/Bourne_again_shell).
* The entrypoint however is the script that is used when the container is run as an executable. By default, it is `/bin/sh -c`, and it can be used to run **any** command in the container, available for the user. However, some people tend to change it.

For our workaround, we need to override the entrypoint, because it is using the default `root` user, and we don't want this.

Let's first add these new instructions in our Dockerfile:

```dockerfile
## Remember to make this script executable!
COPY docker/php/bin/entrypoint.sh /bin/entrypoint

ENTRYPOINT ["/bin/entrypoint"]
```

Remember the image's directory structure at the beginning of this post?

The entrypoint will use `gosu` to use the machine user inside the container:

```shell script
#!/bin/sh

## ./docker/php/bin/entrypoint.sh

set -e

uid=$(stat -c %u /srv)
gid=$(stat -c %g /srv)

if [ "${uid}" -eq 0 ] && [ "${gid}" -eq 0 ]; then
    if [ $# -eq 0 ]; then
        php-fpm
    else
        exec "$@"
        exit
    fi
fi

# Override php-fpm user & group config
sed -i "s/user = www-data/user = _www/g" /usr/local/etc/php-fpm.d/www.conf
sed -i "s/group = www-data/group = _www/g" /usr/local/etc/php-fpm.d/www.conf

# Override native user and use the "_www" one created in the image
sed -i -r "s/_www:x:\d+:\d+:/_www:x:$uid:$gid:/g" /etc/passwd
sed -i -r "s/_www:x:\d+:/_www:x:$gid:/g" /etc/group
chown _www /home

if [ $# -eq 0 ]; then
    php-fpm
else
    exec gosu _www "$@"
fi
```

Yes, this seems hacky. I know, and I wish we could get rid of this with a single option, like `USE_MACHINE_USER=true` or something like that. But this is not possible, as it does not exist.

However, if you install `gosu`, create the `_www` user, customize the `ENTRYPOINT`, add this `entrypoint.sh`, you're almost safe with user permissions.

Phew!

## Cleaning the image

It is known that Docker images can be REALLY heavy. The biggest image I'm using is 475MB and I installed TONS of things on it.<br>
However, when building this image, before I execute the scripts I'm going to give you, it can be like 1GB. This is heavy.

That's why we need to clean it up entirely and remove everything we don't need when delivering this image to the hub:

```dockerfile
    && `# Clean apt cache and remove unused libs/packages to make image smaller` \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $BUILD_LIBS \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/* /var/cache/*
```

You may note the presence of `$BUILD_LIBS`: this is the variable we created in the beginning of the `RUN` script, it stores the system dependencies that we want to remove to make the image lighter. 

## And that's not it!

Now that everything is set up, let's see the **final Dockerfile** we have:

```dockerfile
# ./Dockerfile
FROM php:7.3-fpm

LABEL maintainer="pierstoval@gmail.com"

## Remember to make this script executable!
COPY docker/php/bin/entrypoint.sh /bin/entrypoint

ENTRYPOINT ["/bin/entrypoint"]

## Having it named as "99-..." makes sure your file is the last one to be loaded,
## therefore helping you override any part of PHP's native config.
COPY docker/php/etc/php.ini /usr/local/etc/php/conf.d/99-custom.ini

RUN set -xe \
    && apt-get update \
    && apt-get upgrade -y \
    \
    && `# Libs that are needed and  will be REMOVED in the final image` \
    && export BUILD_LIBS=" \
    " \
    && `# Libs that need to be installed for some dependencies but that will be KEPT in the final image` \
    && export PERSISTENT_LIBS=" \
    " \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        make \
        curl \
        git \
        unzip \
        $BUILD_LIBS \
        $PERSISTENT_LIBS \
    \
    \
    && `# Here come the PHP dependencies (see later in this post)` \
    \
    \
    && `# User management for entrypoint` \
    && curl -L -s -o /bin/gosu https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }') \
    && chmod +x /bin/gosu \
    && groupadd _www \
    && adduser --home=/home --shell=/bin/bash --ingroup=_www --disabled-password --quiet --gecos "" --force-badname _www \
    \
    && `# Clean apt cache and remove unused libs/packages to make image smaller` \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $BUILD_LIBS \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/* /var/cache/*
```

## PHP dependencies

Now that your PHP base Dockerfile is OK, you may need dependencies.

Dependencies can vary: `gd`, `intl`, `apcu`, etc.

Most of them can be installed in different ways (for example, `apcu` must be installed using `pecl`).

This is why I added this line in the Dockerfile:

```
    && `# Here come the PHP dependencies (see later)` \  
```

In **your** Dockerfile, you will end up adding PHP extensions installation here.

For example, here are the instructions to install the `intl` PHP extension:

* Add `libicu-dev` to your `BUILD_LIBS`
* Add these instruction in your PHP Dependencies:<br>
  ```shell script
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl \
  ```
* Done!

Most of the time, installing PHP extensions looks the same as this straightforward example.
 
**Some recommendations though:**

* Most PHP extensions need a system dependency (like `libicu-dev` for the `intl` PHP extension).
* Some extensions will only need the library **at compile time**. This means that you can add the lib to `BUILD_DIR` var safely and let the Dockerfile remove it at the end.<br>

  > **Note:** When doing so, make sure libs are all installed at the beginning and all removed at the end and you don't recompile anything after that, because you might have errors if php recompiles an extension and the headers are not here anymore for other extensions.
* Some other extensions will need the library **at runtime**. For example, `gd` might need some PNG or JPEG libs at runtime. This means you must add them to the `PERSISTENT_LIBS`.<br>

  > **Important note:** This should be done only if you can _test_ by yourself that the lib is needed at runtime. Usually, you can either test it with a call to `php --version`, because it shows an error like `PHP Warning:  PHP Startup: Unable to load dynamic library 'gd.so'`, or you can test your application directly.

A final note (that's a lot of notes, I know): dependencies requirements may vary depending on PHP versions and operating systems. It can be different if you are using Ubuntu, Debian or Alpine as a base image, for example.

## Use it

Build the image with `docker build . -t php73`, and if you need to use it, you can create a container and open a shell in it like this:

```
# Linux/Mac
$ docker run -it --rm -v `pwd`:/srv php73 bash

# Windows
> docker run -it --rm -v %cd%:/srv php73 bash
```

Voilà! You can use it for any project, and it'll work like charm!

Note the volume `-v ...:/srv`: it is important as when opening a shell in the container, `/srv` will be the root directory of your project. 

Remember you can add tons of things to your image: static analysis, Composer, etc., it can be very useful.

Bonus: on Linux you can create an alias in your `.bash*` files in order to simplify calling the image:

```bash
alias php-docker="docker run -it --rm -v `pwd`:/srv php73 php"
```

Use it then like this:

```bash
php-docker any_php_file.php
```

> **Note:**<br>
> Windows does not support aliases, but you can create a `php-docker.bat` Batch file with this:
> ```cmd
@echo off
docker run -it --rm -v %cd%:/srv php73 php
```
> Make sure this file is in your `%PATH%`. I usually create a `%HOME%/bin` directory and update `PATH` manually in Windows environment vars settings.

## That's it (for now)

Once you have set up a base PHP image, you are ready to set up the external services, we will se this in the next post!
