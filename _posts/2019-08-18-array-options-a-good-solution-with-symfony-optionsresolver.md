---
layout: post
title:  'Array options: a solution with Symfony OptionResolver'
date:   2019-08-18 07:30:42 -0500
---

I have to use the PHPWord library to generate a docx file with 748 pages with a very specific page format, and tons of other requirements.<br>
And you know what?<br>
So far, it's just "nice" but "boring".

## A story about "array options"

Array options are something that I encounter more and more, everytime I discover new things. It's present A LOT in Javascript (and that's one reason I dislike many JS libs).

They are a "solution" to avoid having tons of arguments in a function.

Check this picture:

[![Arguments vs array options](/img/array_options_example.png)](/img/array_options_example.png)

On the left, you see a common function with tons of arguments.

On the right, you see the "solution" to avoid tons of arguments: a BIG array that contains the previous arguments.

Such issue can be made stricter with tons of validation rules by using libs like [Symfony OptionsResolver](https://symfony.com/doc/current/components/options_resolver.html), which is a really neat component.

## The good, the bad and the options

What I encounter most of the time is the lack of documentation for these options. Moreover, when you have an object-oriented API that needs options, and it returns an object that also needs options, etc., you end up in what I call the "array options hell".

[![Array options hell](/img/array_options_hell.png)](/img/array_options_hell.png)

* **Pros:**
  * When you **read** this, it's obvious what it does. 
  * Great for readability.
* **Cons:**
  * When you **code** this, you have to open the documentation, and (hopefully) options will be documented (if you're lucky). And most of the time, documentation ends up being like `option_a: does something`, and that's all (okay, I might be exaggerating a bit on this).
  * No static analysis can help us know what options are available, unless there's strict validation in the lib (which there almost never is), like with Symfony's OptionsResolver component suggested above.
  * When an option changes in the library, you will never know automatically.
  * There's no auto-completion, and no IDE can implement auto-completion for such thing without a **reference document**. That's why XML config is nice for example: we can have an XSD file to store all options, their description, and automatically document all the things, and the XSD will follow the lib's releases, therefore any IDE with XML support (which means **almost all IDEs**) will automatically show you that the options may be invalid.

And there are probably more cons.

## Any better solution?

Yes, as suggested, an OptionsResolver can help, because it is an object that's here to validate the incoming array options.

Like, let's take the example above with `$table->addRow(...options...)` coming from PHPWord.

Fortunately, options are documented [in PHPWord's Table documentation](https://phpword.readthedocs.io/en/latest/styles.html#table).

We also have PHPDoc saying that the prototype is `addRow(int $height = null, mixed $style = null)`.

> **Note:** We see that `$style` is `mixed`. According to the documentation, we should pass an `array` here. But if we take a closer look to the code and see how `$style` is used, it could also be an instance of `PhpOffice\PhpWord\Style\AbstractStyle`, which have many different objects, mixed with an `array`. There's no documentation for that. So we'll go for `array` as it's the recommended solution.

Then, it's an array of options.

Instead of using arrays everywhere, let's refactor this!

### Refactoring `addRow()`

I'm taking this method because it's the most straightforward: 3 documented options and a 4th one as argument.

And PHPWord also has tons of Option objects we can use, and there's a specific one for `addRow()` that's internally used.

```diff
class Table
{
-    public function addRow($height = null, $style = null): Row
+    public function addRow(Row $row): void

// ...
```

First, we know that a `Row` object must be passed. It's much clearer. And by the way, `addRow()` returns the same `Row` object, so we can get rid of `return $row;` and the return type since the `Row` object is a mandatory argument already and must be created in the userland.

`Row` has 2 constructor arguments: `$height` and `$style`, the same ones as the old `addRow()`. 
This is fine, since these seem mandatory.

However, `$style` is still `mixed`, and the constructor uses a `RowStyle` object in the end. This means that we could get rid of array as arguments and just refactor it like this:

```diff
class Row
{
-    public function __construct($height = null, $style = null)
+    public function __construct($height = null, RowStyle $style = null)

// ...
``` 

Here, we force the `RowStyle` class to be used. We know then that style will be documented in this object. Plus, no more array options in the first place. Finally, there's also the advantage that if `null` is passed, we can create a default `new RowStyle()`.

> **Note:** `RowStyle` is actually the `PhpOffice\PhpWord\Style\Row` class. It's aliased because there's already a `Row` class in the `PhpOffice\PhpWord\Element` namespace, to avoid conflicts.

Finally, `RowStyle`'s constructor is empty. Let's add the parameters here, and use `OptionsResolver`!

In the following code, the properties already exist. All I'm doing is adding the `getOptions()` method and use the resolver.

```php
<?php
use Symfony\Component\OptionsResolver\OptionsResolver;

class Row extends AbstractStyle
{
    /**
     * Repeat table row on every new page
     */
    private $tblHeader = false;

    /**
     * Table row cannot break across pages
     */
    private $cantSplit = false;

    /**
     * Table row exact height
     */
    private $exactHeight = false;

    public function __construct(array $options = [])
    {
        foreach ($this->getOptions()->resolve($options) as $option => $value) {
            $this->{$option} = $value;        
        }
    }

    public function getOptions(): OptionsResolver
    {
        $resolver = new OptionsResolver();

        $resolver->setDefault('tblHeader', false);
        $resolver->setAllowedTypes('tblHeader', 'bool');

        $resolver->setDefault('cantSplit', false);
        $resolver->setAllowedTypes('cantSplit', 'bool');

        $resolver->setDefault('exactHeight', false);
        $resolver->setAllowedTypes('exactHeight', 'bool');

        return $resolver;
    }
}
```

🎉 Tada! 

* **Pros:**
  * Objects everywhere, which means that with any good IDE we can just open the class or method and see its documentation.
  * Options are defined in a `getOptions()` method, therefore this method could be in a contract (an interface) and be shared across the codebase to define something like a "configurable object".
  * Reading the code in `getOptions()` helps knowing what are the available options, their possible types, values, etc., and way more! `OptionsResolver` can do many more things.
  * We can retrieve the `OptionsResolver` programmatically and use it to generate a base documentation.
* **Cons:**
  * Still an array of options

> **Bottom note:** If you ask me why I don't contribute to PHPWord, well, refactoring an entire codebase with something like that is a huge task, and this post is mostly here for demonstration.
I'm not saying PHPWord is bad. It's good and I use it because it's good.
