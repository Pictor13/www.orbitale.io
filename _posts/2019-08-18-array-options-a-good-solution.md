---
layout: post
title:  'Array options: a good solution?'
date:   2019-08-18 07:30:42 -0500
---

I have to use the PHPWord library to generate a docx file with 748 pages with a very specific page format, and tons of other requirements.
And you know what?
So far, it's just "nice" but "boring".

## A story about "array options"

Array options are something that I encounter more and more, everytime I discover new things. It's present A LOT in Javascript (and that's one reason I dislike many JS libs).

They are a "solution" to avoid having tons of arguments in a function.

Check this picture:

[![Arguments vs array options](/img/array_options_example.png)](/img/array_options_example.png)

On the left, you see a common function with tons of arguments.

On the right, you see the "solution" to avoid tons of arguments: a BIG array that contains the previous arguments.

Such issue can be made stricter with tons of validation rules by using libs like [Symfony OptionsResolver](https://symfony.com/doc/current/components/options_resolver.html), which is a really neat component.

### The good, the bad and the options

What I encounter most of the time is the lack of documentation for these options. Moreover, when you have an object-oriented API that needs options, and it returns an object that also needs options, etc., you end up in what I call the "array options hell".

[![Array options hell](/img/array_options_hell.png)](/img/array_options_hell.png)
