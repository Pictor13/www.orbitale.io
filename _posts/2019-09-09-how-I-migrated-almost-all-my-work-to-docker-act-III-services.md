---
layout: post
title:  'How I migrated almost all my work to Docker Act III: services'
date:   2019-09-09 10:00:00 +0200
---

This post is the third of a series of four posts about how I started to used Docker for all my projects.

If you have not read the other ones, you may give them a go before reading this one:

* [Act I: Genesis](/2019/08/26/how-I-migrated-almost-all-my-work-to-docker-act-I-genesis.html)
* [Act II: PHP](/2019/09/02/how-I-migrated-almost-all-my-work-to-docker-act-II-php.html)
* Act III: Services (current)
* [Act IV: Project](/2019/09/16/how-I-migrated-almost-all-my-work-to-docker-act-IV-compose.html)

## Reminder of previous post

In the previous post, I gave a lot of examples related to PHP with Docker.

This third post will explain how we can migrate of our environment **services** with Docker in order to simplify our lives.

## What is a "service"?

Databases are the most straightforward example, but this is valid for _any_ type of service, could it be a mailer, a queue system or a cache engine.

Usually with PHP setups we start learning by installing an "*AMP" environment (LAMP for Linux, WAMP for Windows, etc.). They mean "Apache, Mysql and PHP".

I will not explain why Apache is a bad solution, there is already a glance of this opinion on my [Apache and PHP-FPM in Windows](/2017/11/11/apache-and-php-fpm-in-windows.html) post, and plenty other resources on the web.

The problem with this setup, when using it natively, is that all three services are tied together and if you don't do PHP, you don't care about it and just want a MySQL server for example. With NodeJS you might not need Apache at all. With Ruby, well you need Ruby of course, and you may need a database.

And this is not only for MySQL: one day you may end up adding a RabbitMQ queue, or a Mailcatcher server to debug your e-mails, or a Redis server for your HTTP sessions, well, at some point you need to install something that needs tons of configuration.<br>
Just like PHP.

Let us follow the paths of installing services **natively** first, and then we will see how to _dockerize_ them.

## MySQL

Okay, let's install MySQL on our machine: `apt-get install mysql-server` (or [follow the guide for Windows](https://dev.mysql.com/downloads/mysql/)).

Now, how do you manage the `root` account in order to create other MySQL accounts?

Well, it depends on your OS, on the way it is installed, on its version, and can also depend on whether you pick MySQL or MariaDB, etc.

Now, let me show you how we can run a MySQL server with one single command using Docker:

```
docker run --name=mysql -dit -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:5.7
```

This will start a MySQL server, expose the `3306` port (default for MySQL) and set it up with `root` as root password.

Really straightforward.

If you want to execute a MySQL shell inside the container:

```
$ docker exec -it mysql mysql -uroot -proot
# ...
mysql> -- Hey, I'm a SQL query!
```

**Bonuses:**

* You can make it **always available** by appending the `--restart=always` option (be careful with that option though, if it bugs or crashes, you'll need to kill & remove the container and recreate it).
* You can **store all data** from it in your machine by adding a volume mounted on the container's mysql `datadir`: `--volume /your/mysql/data:/var/lib/mysql` (customize your mysql data dir), making data persistent even if you remove the container. First path (`/your/mysql/data`) is the path on **your machine**. The second path corresponds to the default place where MySQL stores all your data.
* There also is a solution to not sync data with your machine by creating a custom Docker volume, it might be a bit more advanced, but the advantage is that you can easily remove it with `docker volume rm ...`. I will not give more details, as said it can be a bit more advanced, but just know that it is another possibility.
* You can start **several other mysql servers** with the same or other versions by changing the exposed port and the container name, like `--name=other_mysql -p 13306:3306`.
* It's a one-liner command: **make it an alias** like you did before with PHP!

```
$ alias mysql_docker_install="docker run --name=mysql -dit -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:5.7"
$ alias mysql_docker="docker exec -it mysql mysql -uroot -proot"
```

I am even using it in the scripts I add to [my dotfiles](https://github.com/Pierstoval/dotfiles/blob/master/bin/mysqldocker).

## PostgreSQL

If we can do it with MySQL, we can do it with PostgreSQL!

```
$ docker run --name=postgres -dit -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres
```

Use it:

```
$ docker exec -it postgres psql -Upostgres -W
Password: postgres
psql (11.5 (Debian 11.5-1.pgdg90+1))
Type "help" for help.

postgres=#
```

## Redis

Set it up:

```
$ docker run --name=redis -d redis
```

And use it:

```
$ docker exec redis redis-cli set my_key any_value
OK
$ docker exec redis redis-cli get my_key
any_value
```

## Others...

You can also use mailcatcher, RabbitMQ, mongodb...

Almost every service you already know can be used with this method.

## Disadvantages

* You must remember some bits of their documentation, especially default port.
* You may need to start and stop containers manually, unless using `--restart=always` when creating the container.
* You have to create new containers if you have several apps, or you must use the same container, which can conflict (for example when you use the same keys in Redis in different apps).
* Persistent storages may need more configuration (volumes, mounts, delegates...).

## Advantage of all these new containers

* We can start and stop them with `docker start postgres` or `docker stop postgres`.
* As long as we don't touch anything on the container (recreate/remove/etc), the data in it will be kept between starts and stops.
* Some of them can use persistent storages and put them in files, and most docker images documentations explain what is the directory you should mount as a Docker volume in order to store it on your machine so it can be available even if you recreate a new container. You can also use Docker volumes without sharing them in your machine (Docker will save it somewhere else).
* It can be used by any app, and all you need to do is refer to host `127.0.0.1` and use a port you manually exposed. Be careful not to expose twice the same port to avoid conflicts (Docker does not allow it anyway). Most services will expose their default ports so you can already use a standard (3306 for MySQL, 5432 for PostgreSQL, 6379 for Redis, etc.)
* It can be aliased and used as a starter when you have a brand new machine and you don't want to set up everything on it (you install Docker and all the rest is only "download & run", no config).
* You can use the same version as the one you use on your production server, which is really useful for legacy apps.
* You can create as many containers as you wish with the names you want for several apps on your machine.

## That's it (for now)

To me, the above disadvantages are not _real_ issues. Some of them can be fixed with Docker Compose, and that's for next post where I will show some examples of fully dockerized projects, using Docker Compose.
