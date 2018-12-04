---
layout: post
title:  'The Symfony container graph'
date:   2018-12-04 20:31:46 +0100
---

We may sometimes forget about the fact that we have classes all over the place in our PHP/Symfony projects.

The most important thing is to be able to correctly represent ourselves the hierarchy of the classes themselves.

I created a small dumper that uses the native `GraphvizDumper` from the Symfony DependencyInjection component, because
I have been curious about finding a way to make a graph about all the classes I use.

Fortunately, this dumper has been built-in for a while, it's just not widely used, but it's really interesting to see
what becomes of our container in terms of graphs.

## First, let's use the `GraphvizDumper`

If you want to use this dumper, it's easy! (I know we shouldn't say "easy" in such posts, but, well, I _really_ think
it's easy...)

I'm considering you use Symfony with the Flex architecture (so 3.3+ or 4.0+).

In `src/Kernel.php`, add these lines at the bottom of the `configureContainer()` method:

```php
protected function configureContainer(ContainerBuilder $container, LoaderInterface $loader)
{
    // ...

    // Execute this pass after ALL other passes, so the container can be dumped when asked.
    $container->setParameter('container.dumper.graphivz.enable', 'dev' === $this->environment && $this->debug);
    $container->addCompilerPass(new DumpGraphContainerPass(), 'removing', -2048);
}
```

And create the `DumpGraphContainerPass` in the `src/` directory (don't need to put it anywhere else, after all, you
shouldn't probably use this very often).

```php
<?php

namespace App;

use Symfony\Component\DependencyInjection\Compiler\CompilerPassInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Dumper\GraphvizDumper;

class DumpGraphContainerPass implements CompilerPassInterface
{
    public function process(ContainerBuilder $container)
    {
        $parameterEnable = 'container.dumper.graphivz.enable';
        $parameterFile = 'container.dumper.graphivz.file';

        if (!$container->hasParameter($parameterEnable)) {
            $container->setParameter($parameterEnable, false);
        }

        if (!$container->hasParameter($parameterFile)) {
            $container->setParameter($parameterFile, $container->getParameter('kernel.cache_dir').'/container.dot');
        }

        if (!$container->getParameter($parameterEnable)) {
            return;
        }

        \file_put_contents($container->getParameter($parameterFile), (new GraphvizDumper($container))->dump());
    }
}
```

And it's done!

Just run your application anytime and anyhow (just running `php bin/console` should do the trick).

## See the final graph

When you have dumped the container thanks to the above classes, you can now view it with Graphviz.

Ensure you have the `dot` binary available in your environment by installing [Graphviz executables](https://www.graphviz.org/)
for your environment (I tested this on Windows, so you can use it anywhere).

Once installed, use it like this:

```
$ dot -Tsvg var\cache\dev\container.dot > container.svg
``` 

Open `container.svg` with your favourite software and enjoy!

## The Symfony container graph

I used this to dump the container after a raw `composer create` with the different skeletons, enjoy:

### Container from `symfony/skeleton`

[![Container from symfony/skeleton](/img/symfony_skeleton_container.svg)](/img/symfony_skeleton_container.svg)

### Container from `symfony/website-skeleton`

[![Container from symfony/website-skeleton](/img/symfony_website_skeleton_container.svg)](/img/symfony_website_skeleton_container.svg)

## But... why?

I did this at first because I'm curious.

Of course this graph is quite unreadable, but it's really interesting to navigate through it.

Just imagine now using this on a way bigger application (I did this on [Studio Agate](https://www.studio-agate.com/en)'s
one, it's reaaaally bigger), astonishing, isn't it?

I published this on this blog to maybe remind everyone that our applications are not a pile of code.

It's also the result of hundreds and thousands of hours of work, thoughts, brainstorming, knowledge, sharing, 
discussions and debate from tons of developers, and this is what makes our application so nice.
