---
layout: post
title:  '[PHP Basics] Functions and methods prototypes'
date:   2017-10-25 11:29:57 +0200
---

A PHP function is made of three things:

* Its code
* Its documentation (using PHPDoc)
* Its prototype

In PHP, a function prototype (also called "signature") is made of the **name**, **arguments** and, since PHP 7, its
 **return type**.

Arguments can be typed, we call this "type-hint", and since PHP 7 we can type an argument with scalar types (`bool`, 
 `int`, `string`...), but since early PHP has objects, we can type-hint with a class. Also, arguments can have a 
 default value.
 
Basic example:
```php
public function __construct($a, $b, $c) { /* */ }
```

Here, no type, but signature is using 3 arguments.

Full example:
```php
public function loginAction(Request $request, string $username, bool $useReferer = true): Response
{
    // ...
}
```

Here, we have a scalar type-hint for `$username` and `$useReferer`, and object type-hint for `$request`.
We even have a default value for `$useReferer` which is `true`.

The return type, here, is an `Response` object type. This means that `loginAction()` **MUST** return an instance of the
  `Response` class, else PHP throws an exception at runtime.

Return type is similar than argument type: it accepts classes and scalars, but since PHP 7.1, it also accepts a special
return type: `void`.

The `void` return type means that the `return` instruction in the method / function must **never** have argument. With
  a `void` return type, we can never do something like `return 1;` or `return $response`, else PHP throws an exception
  at runtime.<br>
We can only do `return;` with this type.

But nothing prevents doing such things: 

```php
function test(): void {
    echo "ok";
    
    return;
}
$a = test();
var_dump($a);
// Outputs:
// "ok"
// null
```

See the [void RFC](https://wiki.php.net/rfc/void_return_type) for more information.
