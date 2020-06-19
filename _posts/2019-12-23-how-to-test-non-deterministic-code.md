---
layout: post
title:  'How to test non-deterministic code?'
date:   2019-12-24 12:30:01 +0200
---

> **Note:** This post is a translation of another post I wrote in french for the [AFSY's Advent Calendar here](https://afsy.fr/avent/2019/19-comment-tester-du-code-non-deterministe). Enjoy!

I don't know if you noticed, but there are certain development teams that do strange things with their projects. Things that everybody talk about, but we rarely see them.

Not ghosts, no.

I'm talking about tests.

And most often, when we talk about tests, we see this kind of thing:

```php
class Math
{
    public function add(float $a, float $b): float
    {
        return $a + $b;
    }
}
```

```php
use PHPUnit\Framework\TestCase;

class MathTest extends TestCase
{
    public function testAdd(): void
    {
        $math = new Math();

        static::assertSame(3, $math->add(1, 2));
    }
}
```

Whoa! 🎉

Awesome, we know how to test our code!

This code has something special: it is **deterministic**.

## Some explanations

According to [Wiktionary](https://en.wiktionary.org/wiki/determinism), here is the definition of determinism:
> Determinism: (computing) The property of having behavior determined only by initial state and input.

This means that if you know the initial input parameters, you can predict the output, whatever the situation.

Most things we do in computing are deterministic because they depend on "fixed" data. A number, a string, a date, etc.

However, sometimes our algorithms have specific needs that need non-deterministic code.

It's the case for example when handling **random data**.

Generate an identifier unique in all the universe, or random data in general, is a hard task for a computer. What is even harder is predicting the result.

With standards like [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier), we can know the **size** and **format** of the output information, but not the **content**. Algorithms are made brilliant enough so it's "almost impossible" to have twice the same value with two different computers.

The thing is that your code can depend on this kind of situation.

## An example

I will take the example of a project I've been working on for a few years already and that is linked to a [role playing game](https://en.wikipedia.org/wiki/Tabletop_role-playing_game).

When one creates a character in a role-playing game, they often have to throw dices 🎲 to determine the score of a characteristics or skill. It therefore is a **random** value. 

If you are used to dice rolls, we can represent a dice throw with the format `2d6+3`, corresponding to a throw of two six-sided dice, which total is added 3. We then need 3 parameters as input (to simplify, obviously): the number of dice, the number of sides per dice, and an additionnal bonus to add at the end.

## Generating randomness

Let's create the service that will make dice rolls:

```php
namespace App;

class DiceRoller
{
    public function roll(int $numberOfDice = 1, int $diceSides, int $bonus = 0): int
    {
        $result = $bonus;

        for ($i = 0; $i < $numberOfDice; ++$i) {
            $result += random_int(1, $diceSides);
        }

        return $result;
    }
}
```

> Note: the class is in the `App` namespace, and that for a good reason (read more of this post to know why).<br>
> In general, in your projects, all your classes will be in namespaces.

We use `random_int()`, a native PHP function used to generate a random integer between two numbers.

Once done, we can use it in our own services:

```php
// Roll 2d6+3
$diceRoller->roll(2, 6, 3);
```

> Note: all numbers should be validated to be **positive** integers, this is a logic requirement, but we won't go back on this because it's just an example. Note that if you have to implement such system, you will need to validate input data.

One question still subsists though: **How to test this code?**

The answer is not simple but there exists different cases:

* Directly test the `DiceRoller::roll()` method
* Test a service that _depends_ on `DiceRoller`

Strangely, the second case is far simpler to test than the first.

## Test the code that generates random data

To test the `DiceRoller`, I will progressively propose three alternatives, in their order of "liability".

We'll consider that PHPUnit will be used to test the code.

## First attempt: Make a consequently huge amount of tests.

This solution looks like this:

```php
namespace Tests\App;

use App\DiceRoller;
use PHPUnit\Framework\TestCase;

class DiceRollerTest extends TestCase
{
    /**
     * @dataProvider provide dice rolls
     */
    public function test dice roller result is in dice range(int $numberOfDice = 1, int $diceSides, int $bonus = 0): void
    {
        $diceRoller = new DiceRoller();

        $result = $diceRoller->roll($sides, $multiplier, $offset);

        static::assertGreaterThanOrEqual(1 * $multiplier + $offset, $result);
        static::assertLessThanOrEqual($sides * $multiplier + $offset, $result);
    }

    public function provide dice rolls(): \Generator
    {
        $sidesToTest = [4, 6, 8, 12, 20]; // d4, d6, etc.
        $numberOfDicesToTest = range(1, 10); // Up to 10 dices at the same time.
        $bonuses = [1, 2, 3, 4, 5]; // Not too much, that's already a lot.

        foreach ($sidesToTest as $diceSides) {
            foreach ($numberOfDicesToTest as $numberOfDice) {
                foreach ($bonuses as $bonus) {
                    yield "$diceSides-$numberOfDice-$bonus" => [$diceSides, $numberOfDice, $bonus];
                }
            }
        }
    }
}
```

When running the tests, we will have something like this:

```
/var/www/dice_roller $ php phpunit.phar DiceRollerTest.php
PHPUnit 8.4.3 by Sebastian Bergmann and contributors.

...............................................................  63 / 250 ( 25%)
............................................................... 126 / 250 ( 50%)
............................................................... 189 / 250 ( 75%)
.............................................................   250 / 250 (100%)

Time: 130 ms, Memory: 18.00 MB

OK (250 tests, 1000 assertions)
```

Here we might say _"Great! I have 250 tests for my class, it's wonderful!"_.

But it is not.

In fact, with the code above, we have one problem: every call to `$diceRoller->roll()` will generate a random number and we have **no way to predict its value**. The only thing we can do (and that is done in this test) is to predict **its possible values**. As our code is well made, it will work as expected anyway.

To attempt to solve this issue, we may try to determine **statistically stable solutions**.

If we execute a lot of dice rolls, like `2d6+3`, depending on the number of throws, the average result is different, because at first the random numbers that PHP generates are not "really random", we say they are "pseudo-random", and next, because the distribution of the results can be "stable" only with a statistical and theoretical point of view. In practice, it is rarely the case (as well as any random-based system, in the end...)

Let's create a small script to make a high number of dice rolls:

```php
$diceRoller = new App\DiceRoller();

$count = 1000000;
$results = [];

for ($i = 1; $i <= $count; $i++) {
    $results[] = $diceRoller->roll(2, 6, 3);
}

// Average value
echo array_sum($results) / $count, "\n";
```

Now, execute it several times, just to see the different average values (with a million throws each time):

```
/var/www/dice_roller $ for i in {1..10}; do php roll.php; done
11.998764
11.997870
12.003618
12.000348
11.999262
11.998068
11.993424
12.000720
12.003618
12.000378
```

We directly see that the average of total scores always revolve around 12, but is never _equal_ to 12.<br>
We cannot even make a huge number of dice rolls and calculate the average... Or we could do it, but we will have to consider that with a considerably high number of tests come an error threshold on the average.

We then have a "solution", but it is quite a rough one.

## Second idea: override `random_int()`

Thanks PHP! Once more!

Thanks to PHP, there are some ways to override a native function. A long time ago there was the `override_function()` function, but it was part of the APD (Advanced PHP Debugger) extension, which was abandoned in... 2004.

The best way is **namespace override**.

When your code is located in a namespace and you execute a native function (any function), PHP will first make a namespace lookup to see if the function exists in the current namespace, and if it does not, will fall back on the global namespace.

This override is by the way the one used by the `DnsMock` and `ClockMock` of the Symfony PHPUnit Bridge to allow us to override native functions for DNS lookups or date and time functions.

Here is how to proceed:

In your `DiceRollerTest` class, you can declare an additional namespace of any kind.

The namespace to add **must be the same of the original `DiceRoller` class**, because it's this class that executes the native function we want to override.

```php
namespace Tests\App;

use App\DiceRoller;
use PHPUnit\Framework\TestCase;

class DiceRollerTest extends TestCase
{
    // ...
}

namespace App;

// Function override
function random_int() { /* */ }
```

Voilà! With this method, when the `DiceRoller` executes the `random_int()` function while in our tests, PHP will first search if it is defined in the associated namespace (`App` in our case) and will execute the function you created!

This way, you might, for instance, execute a function of a static class that would allow you to define the result you want before executing the test:

```php
namespace Tests\App;

use App\DiceRoller;
use PHPUnit\Framework\TestCase;

class DiceRollerTest extends TestCase
{
    public static int $forcedResult = 0;

    public function test(): void
    {
        $diceRoller = new DiceRoller();

        self::$forcedResult = 1;

        $result = $diceRoller->roll(2, 6, 3);

        static::assertSame(5, $result); // Yay!
    }
    // ...
}

namespace App;

use Tests\App\DiceRollerTest;

// Function override
function random_int(int $min, int $max): int {
    return DiceRollerTest::$forcedResult;
}
```

This solution works well, **but it has a drawback**: if one day the code of the `DiceRoller` class changes and the call to `random_int()` is done with the `\random_int()` syntax (or when the `use function random_int;` statement is added on top of the file), it's over!<br>
This syntax will force PHP to use only the native function and you will never be able to override `random_int()`.

Don't worry though, I have the solution!

## Third solution: the ultimate solution!

The notion of "randomness" as you read above (and if you know the issues related to "randomness in computer science") is quite peculiar. It is like fetching the date, or the stock exchange rates: it is not 100% predictible and needs an "external service".

Randomness generators use serveral techniques, some _hacks_, to allow you to have something that _looks_ random. 

In fact, **a random number generator is a third-party service**.

You see where I'm coming?

Here it is: the `DiceRoller` could perfectly work **without `random_int()`**! However, it cannot work **without a random number generator**.

We will then create an interface to represent our needs, which is straightforward enough for our problem:

```php
namespace App;

interface RandomIntProviderInterface
{
    public function randomInt(int $min, int $max): int;
}
```

And of couse we will have to change the code of our `DiceRoller` class:

```php
namespace App;

class DiceRoller
{
    private RandomIntProviderInterface $randomIntProvider;

    public function __construct(RandomIntProviderInterface $randomIntProvider)
    {
        $this->randomIntProvider = $randomIntProvider;
    }

    public function roll(int $numberOfDice = 1, int $diceSides, int $bonus = 0): int
    {
        $result = $bonus;

        for ($i = 0; $i < $numberOfDice; ++$i) {
            $result += $this->randomIntProvider->randomInt(1, $diceSides);
        }

        return $result;
    }
}
```

(Note how I subtly added a typed property, thanks PHP 7.4!)

Excellent!

The next step is to create two classes: one for the application in its "normal behavior":

```php
class NativeRandomIntProvider implements RandomIntProviderInterface
{
    public function randomInt(int $min, int $max): int
    {
        return \random_int($min, $max);
    }
}
```

This class will be injeced in the `DiceRoller` constructor with your favourite Dependency Injection system (Symfony's one, by any chance).

Then, for the sake of our tests, we will create another implementation:

```php
class DeterministicRandomIntProvider implements RandomIntProviderInterface
{
    public int $determinedResult = 0;

    public function randomInt(int $min, int $max): int
    {
        return $this->determinedResult;
    }
}
```

Perfect!

Here is then what our test might look like for the `DiceRoller` class:

```php
class DiceRollerTest extends TestCase
{
    public function test dice roller result is in dice range(int $sides, int $multiplier, int $offset): void
    {
        $randomIntProvider = new DeterministicRandomIntProvider();

        $diceRoller = new DiceRoller($randomIntProvider);

        $randomIntProvider->determinedResult = 1;

        $result = $diceRoller->roll(2, 6, 3); // 2d6+3

        static::assertSame(5, $result); // Yay!
    }
}
```

Marvelous! We can now force the "random" number provider to return a specific number and then we have a total control over our architecture in order to test it!

## Conclusion

Generating non-deterministic data (dates, random numbers, unique identifiers, secret keys...) is a real challenge for people writing these tools.

As we often do not have the control over these advanced systems using sometimes very complex cryptography or wacky techniques like climate fluctuations, [quantum cryptography](https://en.wikipedia.org/wiki/Quantum_cryptography) or even [lava lamps](https://www.zdnet.com/article/how-lava-lamps-are-used-to-encrypt-the-internet/), we often (always?) have to handle a multitude of possible results by ourselves.

Assuming that non-deterministic data is **data coming from a third-party service** allow us to better structure our code and make it more flexible and also adapted to a deterministic version instead of a random one of this particular external data.

There is for instance the [`nesbot/carbon`](https://github.com/briannesbitt/Carbon) library allowing to consider that the date and time can be coming from an external system, so we can "fake" this date by providing a [static testing API](https://carbon.nesbot.com/docs/#api-testing) for our special needs (dates comparison, fake the passage of time in a single test, etc.). 
