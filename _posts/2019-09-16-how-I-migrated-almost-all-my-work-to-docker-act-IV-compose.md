---
layout: post
title:  'How I migrated almost all my work to Docker Act IV: Compose'
date:   2019-09-16 10:00:00 +0200
---

This post is the last one of a series of four posts about how I dockerized all my projects.

If you have not read the other ones, you may give them a go before reading this one:

* [Act I: Genesis](/2019/08/26/how-I-migrated-almost-all-my-work-to-docker-act-I-genesis.html)
* [Act II: PHP](/2019/09/02/how-I-migrated-almost-all-my-work-to-docker-act-II-php.html)
* [Act III: Services](/2019/09/09/how-I-migrated-almost-all-my-work-to-docker-act-III-services.html)
* Act IV (current)

## Reminder of previous posts

In the previous posts, we saw how to use Docker to simplify services creation for many subjects: PHP at first, and other services after, like MySQL, Redis, etc.

This last post will focus on **projects**.

To help dockerizing a project, here comes our savior: Docker Compose!

## Compose? Like, with music?

Compose, Composer, Symfony, Sonata... Do devs love music? Anyway, get back to the subject.

Docker Compose is a tool that is provided with Docker in order to create multi-container applications, link them together, and store the app's configuration in one single file: `docker-compose.yaml` (Yeah, I know... Yaml...).

As said in the first post of this series, I assume you know the basics of Docker Compose.

## Compose a base PHP project

What does PHP need to work when building a standard project? Most of the time: a web-server (we'll use `nginx`), `php-fpm` (else, no PHP, of course), and possibly a database (we'll use `mariadb`).

The best example is a Symfony project: if you create a project based on the `symfony/website-skeleton`, it will come with Doctrine ORM, therefore need a relational database (MySQL, MariaDB, PostgreSQL...). 

Let's create the base services:

```yaml
version: '3'

services:
    php: # Here will come something

    database: # Something else here

    http: # And here something else again.
```

> **Note:** Remember in the [second post](/2019/09/02/how-I-migrated-almost-all-my-work-to-docker-act-II.html) when I talked about permissions?
> Please be aware that **any container that will touch your files must handle permissions correctly**. Therefore, for any service you create that may have a shared volume with your machine, you **must** create a base Docker image and use the proposed hack to make sure permissions are handled correctly.
> Of course, as the hack I added to this post is focused on `php-fpm`, you must adapt it to the script you need to run, be it nodejs, mysql or anything.

### PHP

Your PHP container will need an image, as it will certainly modify your files, and of course you will need a specific PHP configuration or additional extensions.

I won't show the Docker image because you already know it after the second post of this series.

Here is a sample PHP service I may recommend:

```yaml
services:
    php:
        build: .            # The PHP dockerfile is better at the root of the project
        working_dir: /srv   # As we used /srv in the image already
        volumes:
            - ./:/srv       # Necessary, so PHP can use your source code :p
        links:
            - database      # This is to help you connect to your database later
```

This could be optimized a bit, but for now it should be fairly enough.

Don't forget to create the `docker/php/etc/php.ini` and `docker/php/bin/entrypoint.sh` and add `COPY` statements in your Dockerfile, as exposed in the second post of this series.

### MariaDB

A database service is quite straightforward to set up too:

```yaml
services:
    database:
        image: mariadb:10.4     # It is a good practice to specify at least the minor version
        volumes:
            - db_data_volume:/var/lib/mysql

volumes:
    db_data_volume: 
```

Here we are using a trick: the `db_data_volume` is here to make sure the data is persistent. If we execute `docker-compose down` and remove the container, the data will be kept anyway.

There is a [nice explanation](https://stackoverflow.com/questions/39175194/docker-compose-persistent-data-mysql/39208187#39208187) on StackOverflow that gives more details about what I'm saying here (remember to upvote the answer if you think it's useful, the author of the answer will thank you).<br>
For example, answers explain that MySQL has permissions issues whereas MariaDB does not. Good point for the great open-source fork of MySQL :)

### Nginx

And here comes some difficulties. Don't worry, you won't lose hair ☺.

Here, we need to set up an `nginx` server.

However, a server needs a vhost, so you will have to create it and inject it in your image.

Step 1: create a Compose service:

```yaml
services:
    http:
        build: ./docker/nginx/
        working_dir: /srv/
        ports: 
            - '8080:80'         # You could also use no port and only override it in a "docker-compose.override.yaml" 
        links: 
            - 'php'             # Mandatory, to proxy the request to php-fpm
        volumes:
            - './:/srv'         # Mandatory to serve static files before calling php-fpm
```

Note that such behavior would be the same for any web-server + proxied handler (like php-fpm, Phusion Passenger, or even multiple apps).

You could even go further for bigger apps by adding a Traefik, HAProxy or Varnish reverse proxy...

Step 2: create the Dockerfile for `nginx`:

```dockerfile
FROM nginx:alpine

COPY vhost.conf /etc/nginx/conf.d/default.conf
```

(here, no problem to use Alpine, because we don't have anything to install)

Step 3: create the `nginx` virtual host (check out the comments for more info about directives)

> **Note:** This vhost is optimized for a Symfony app, but you could adapt it for any other PHP app.

```
server {
    listen 80;

    # This is the public directory of your project that nginx must serve.
    root /srv/public/;

    # Try to serve file directly, fallback to rewrite.
    location / {
        try_files $uri @rewriteapp;
    }

    # Rewrite all to index.php. This will trigger next location.
    location @rewriteapp {
        rewrite ^(.*)$ /index.php/$1 last;
    }

    # Redirect everything to the php container
    location ~ ^/index\.php(/|$) {
        include fastcgi_params;

        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        # try_files resets $fastcgi_path_info, see http://trac.nginx.org/nginx/ticket/321, so we use the if instead
        fastcgi_param PATH_INFO $fastcgi_path_info if_not_empty;

        if (!-f $document_root$fastcgi_script_name) {
            # check if the script exists
            # otherwise, /foo.jpg/bar.php would get passed to FPM, which wouldn't run it as it's not in the list of allowed extensions, but this check is a good idea anyway, just in case
            return 404;
        }

        # The host should be the name of the PHP container,
        # and the port must be the php-fpm's one,
        # which is usually 9000 as it's php-fpm's default.
        fastcgi_pass php:9000;
    }

    # Return 404 for all other php files not matching the front controller.
    # This prevents access to other php files you don't want to be accessible.
    location ~ \.php$ {
        return 404;
    }
}
```

As you can see, configuring Nginx costs a bit more. It is quite heavy, but I think it's mandatory to cover all cases.<br>
Comments in this config file are important, so read them, it'll help you understand why it's here.

[Okty.io](https://okty.io/), a generator for Docker Compose boilerplates, has a [Symfony 4 template](https://okty.io/generator/load/symfony4), and its `nginx` Dockerfile is lighter, but I'm not sure it would be 100% compatible with all features.

Again, it's just a proposal, an example, so you may do whatever you like 😃.

After that, the boilerplate is ready!

## So what now?

Summary:

* We created a `php` service that will create a container for a PHP image of your own, and it will serve a `php-fpm` instance
* We created a `database` service that will create container for a MariaDB image, it will simply serve a `mariadb` server
* We created an `http` service that will create a container for an Nginx image, it will serve an `nginx` server that will serve files from the `public/` project directory, and proxy all other requests to the `php` container.

This is the simplest approach for a PHP project.

So what now?

Well, start coding, of course!

Or wait a little and read until the end 😉.

We can now add many more things:

* A `redis` service and use it in our application for sessions, cache...
* A `mailcatcher` service to debug emails
* A `rabbitmq` service to serve and handle queues
* A `traefik` proxy to natively serve HTTPS requests
* A `varnish` reverse proxy for HTTP caching
* A `blackfire` service to serve as blackfire agent
* A `nodejs` service to generate our web assets
* Etc.

## Bonus point: make this much handier with a Makefile

I really like Makefiles. And they work on Windows! (Yes, they do! Read until the end to know how)

A `Makefile` is a file that define recipes for the famous `make` tool (that is here since 1977, just to say).<br>
We usually place it at the root of the project.

One `make` command may contain three things:

* A target
* A recipe
* Optional dependencies (on other targets)

The target will be the command you have to execute. It can be a file or an abstract name.

The recipe is the list of commands to execute.

I will not say more about Make, 

### A base Makefile for any Docker Compose project

```makefile

# This var will be used to tell the Makefile where to find docker-compose's binary.
# This is something you should do for anything that may be executed by several recipes,
# like when you need to execute PHP, MySQL, etc.
DOCKER_COMPOSE = docker-compose

##
## Project
## -------
##

.DEFAULT_GOAL := help
help: ## Show this help
	# Don't really mind how this command works, just know that it is here to 
	# display a beautiful list of all Make targets for this Makefile.
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help

build:
	-@$(DOCKER_COMPOSE) pull --parallel --quiet --ignore-pull-failures
	$(DOCKER_COMPOSE) build --pull
.PHONY: build

kill:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
.PHONY: kill

install: ## Install and start the project
install: build start
.PHONY: install

reset: ## Stop and start a fresh install of the project
reset: kill install
.PHONY: reset

start: ## Start the project
	$(DOCKER_COMPOSE) up -d --remove-orphans --no-recreate
.PHONY: start

stop: ## Stop the project
	$(DOCKER_COMPOSE) stop
.PHONY: stop
```

Some notes about this Makefile:

* Run the `make help` command, it will execute the `help` target that shows a nice list of all `make` commands you can execute on this project.
* The `.PHONY:` statement tells `make` to always execute this target, even if the target's file is up to date. This is needed for targets that _may_ correspond to a file. It is inherent of `make`'s behavior: if the target **is** a filename, `make` will save its last modify date, and if it's up-to-date, `make` will not execute the recipe. That's why I'm using `.PHONY`, to be sure `make` always execute the recipe, regardless of the target being an up-to-date file or not.
* If you prefix a command in the recipe with `@`, it will not display the full command instruction. If you don't, `make` shows the full command instruction in the terminal when executing it. The `@` prefix will then make the command-line a bit lighter & cleaner.
* If you prepend the `-` character to a command in the recipe, it will execute all the next commands even if the command returned a non-zero exit code (a.k.a "if it failed"). 
* The reason why we have two `install` or `reset` targets is because it's handier to write the comment AND add the dependencies to this target (because `install` depends on `build` and `start` for instance). We could remove the two commands and append the comment right after the dependencies, it would work the same way, but it's much handier like this, at least for readability inside the Makefile itself.

### Bottom-note: using `make` on Windows

I tried several already-compiled `make` binaries on Windows, but the only one that satisfied me (and that is the **latest** version of GNU Make) is the one provided by the [Ruby Devkit](https://rubyinstaller.org/downloads/).

The drawback is that we have to install Ruby... But it also comes with tons of UNIX tools (awk, sed, grep, etc.), so I don't mind, it's good anyway 🤠. 

## Conclusion

Docker is not mandatory, but it comes with lots of advantages.

Thanks to Docker Compose, I will spend a bit more time on setting up the project, but way less configuring my entire machine.<br>
And this config will be shared with all people working on the project.

I think it's really cool.

And you? 😉

Thanks for reading! 
