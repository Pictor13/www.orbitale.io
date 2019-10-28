---
layout: post
title:  'What is a Controller?'
date:   2019-07-19 02:01:09 +0200
---

In the programming industry we often bang our heads on walls by talking about things instead of coding. Like "best practices", "best language", "best IDE", etc.

Today, I saw a question that made me dive into such interrogation:

[![Question about controllers](/img/controller_question.jpg)](https://twitter.com/barryosull/status/1151812280537047040)

This is a really interesting question.

The reason someone may have this question may be caused by the vagueness of how MVC was implemented over the past decades.

People tend to mislead about controllers.

Ask for "What is a Controller" and you'll see that frameworks and devs all have different opinions.

In MVC apps/frameworks, Controllers tend to be *classes* that can contain many *actions* (action = use case). And one single *action* may execute *multiple tasks* (handle form, send email, save in database, etc.)

I see some answers are talking about SOLID principles, and they're right: respecting the SRP (Single Responsibility Principle) is important to make sure your code is decoupled.

So...

## What **is** really a Controller?

For MVC frameworks, a controller is a class.

But if you look closely, controllers are **not classes**.

Let's take the example of Laravel.

[The docs say this](https://laravel.com/docs/5.8/controllers#basic-controllers):

```php
<?php

namespace App\Http\Controllers;

use App\User;
use App\Http\Controllers\Controller;

class UserController extends Controller
{
    public function show($id)
    {
        return view('user.profile', ['user' => User::findOrFail($id)]);
    }
}
```

```php
<?php
Route::get('user/{id}', 'UserController@show');
```

For Symfony, the example is really similar, as stated in the ["Getting Started" guide to create a page](https://symfony.com/doc/current/page_creation.html#creating-a-page-route-and-controller):

```php
<?php
// src/Controller/LuckyController.php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;

class LuckyController
{
    public function number()
    {
        $number = random_int(0, 100);

        return new Response(
            '<html><body>Lucky number: '.$number.'</body></html>'
        );
    }
}
```

```yaml
# config/routes.yaml

# the "app_lucky_number" route name is not important yet
app_lucky_number:
    path: /lucky/number
    controller: App\Controller\LuckyController::number
```

**State: a controller is Note a class**

When we look at it, a controller is just a **callable**.

This means that our classes should not even be suffixed `Controller` but more `Controllers`.

There's a potential solution: the ADR pattern

## The ADR pattern: Action, Domain, Responder

[The ADR pattern](https://en.wikipedia.org/wiki/Action%E2%80%93domain%E2%80%93responder) is popular amongst many "best-practices-first" projects that rely a lot on good design patterns.

MVC is vague, and doesn't really state about "what a controller is" (hence this post).

ADR is more strict and cuts the structure into logic domains. A small example: the "View" part (the "Responder" in ADR) cannot act on the domain, it only receives data and respond with a view, and should not update anything related to the domain/model.

I won't dig too much about ADR, but what is clear with ADR is that the HTTP action is represented by one single Action, and in this case, an explicit `callable` that only information about the HTTP layer (like Request) and interact with the _domain_.

This means that ADR can recommend one action per controller class, represented by a single `callable`.

## Another problem with multiple actions in controllers

Dependencies.

When you have a class with multiple actions, you often need dependencies, like a template engine, a router, a form handler, a command bus, whatever you may need to interact with the domain or ask for a responder.

If you have, let's say, a "list" action and an "edit" action, the "list" will only need the repository to fetch the list of objects, but "edit" will need the form layer. This means that you will either need this:

```php
<?php
class PostController
{
    public function __construct(PostRepository $repository, FormFactoryInterface $formFactory)
    {
        $this->repository = $repository; 
        $this->formFactory = $formFactory; 
    }
    public function list()
    {
        // ...
    }
    public function edit(string $id)
    {
        // ...
    }
}
```

In this case, the `formFactory` will be useless for the `list` action, therefore instantiating a service for nothing.

With Symfony, this could be fixed with a dirty hack: 

```php
<?php
class PostController
{
    public function list(PostRepository $repository)
    {
        // ...
    }
    public function edit(string $id, PostRepository $repository, FormFactoryInterface $formFactory)
    {
        // ...
    }
}
```

This solution comes from the fact that you can use Dependency Injection directly in controller actions, [as stated in the docs](https://symfony.com/doc/current/controller.html#fetching-services), but I don't like this idea at all, and it's another subject this post will not cover.

This still shows us that controllers are only callables, nothing more.

With one single action per controller, this problem no longer occurs.

## Conclusion

Single-action controllers are better for consistency, maintenance, clarity...

When looking for an action, you look at either the route or the class itself, and if you also respect the "thin controllers" good practice, maintaining a controller is easier because you only call business logic, therefore focus on your logic rather than your architecture.

Good practices help us focus on the wellness of our code.
