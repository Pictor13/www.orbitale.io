---
layout: post
title:  '[Gist] Regular expression for ImageMagick "Geometry"'
date:   2016-03-25 10:12:43 +0200
---

Some time ago, I created [ImageMagickPHP](https://github.com/Orbitale/ImageMagickPHP), a PHP library that allows you to
create ImageMagick commands similar to what we can do in command line with
[convert](http://www.imagemagick.org/script/convert.php) or [mogrify](http://www.imagemagick.org/script/mogrify.php)
for example.

This lib is still a "Work in progress", but it stores all common command instructions, you're able to prepend/append
informations depending on the instruction type, etc., and when you run the command you get a
[CommandResponse](https://github.com/Orbitale/ImageMagickPHP/blob/master/CommandResponse.php "CommandResponse.php")
object that you can use to check whether the command failed or not.

But, the hardest part of this library was that when processing images, for example if you want to
[resize](http://www.imagemagick.org/script/command-line-options.php#resize) it, you need to pass a
[Geometry](http://www.imagemagick.org/script/command-line-processing.php#geometry) argument, which represents the "way
you want to resize" your image.

For example you can use this:

```
$ convert my_image.jpg -resize 250x350 output.jpg
```

This will resize to 250×350 but will keep proportions and ratio, so if your image is a square of 1500×1500 pixels, it will be resized to the _lowest_ value of the ratio, so your image will be 250×250 in fine. There are plenty of other things you can do with Geometry arguments.

For example, you can [crop](http://www.imagemagick.org/script/command-line-options.php#crop) an image.
Let's get an example:

We want to crop this image in the red zone:<br>
![Orbitale logo](/img/regex_image_to_crop.png)<br>
<br>
We'll crop it to get just a portion of the center of the image.
As a reminder, it's 322×322 px wide.

```
$ convert logo.png -crop 160x160+80+80 output.png
```

Here's the result:<br>
![output](/img/regex_image_cropped.png)<br>
<br>
The Geometry argument was the following: **160×160+80+80**.

Images are analyzed as bitmaps, so if we say "coordinates 0,0" it is interpreted as the top left of the picture.

The first value is the offset "to the bottom", and the second is the offset "to the right".

So with the above command, we want a picture that is **160×160** pixels wide and that starts 80px to the bottom and 80px to the right.

What was cropped actually was this:<br>
![final](/img/regex_image_crop_zone.png)<br>
<br>
The problem is that Geometry arguments are veeeeeery complex to parse.

If you read the docs of the Geometry argument, you may have noticed that it's extremely flexible but some parts are very
restrictive.

For example, you can use **200×250**, **200** (only 200 with), **×250** (only height), but not **200×** because it's an
error.

There are more tricks to see, but we have to think very hard when we want to validate the Geometry option in the
ImageMagick PHP command.

As you can see in the [GeometryTest](https://github.com/Orbitale/ImageMagickPHP/blob/master/Tests/GeometryTest.php)
class, I tested **all** different geometry combinations and asked ImageMagick whether it works or not.

Some fails were surprising, some not.

But the validator was made **from this tests**, actually.

This regex was developed at first, but it did not suit effectively all the needs, so all possible tests were written and
then regexp was adapted to what ImageMagick answered (success or failure).

* First, numbers should be checked, to see if they were valid.
* In fact, numbers are restricted to a single pattern in ImageMagick commands, so I used it in all other portions of the
regexp.
* Then, we need to check `width` and `height`, which can be both present or not, and which can be calculated in
percentage OR in pixels.
* Then, the `aspect ratio` flag, which can be present only if width and/or height are present.
* After that, the `offset`, which can be present even if there are no width nor height.

Thanks to the great PCRE regexp I could add identifiers to each part of the regexp so a `preg_match` would allow using
the `$matches` argument to retrieve all Geometry informations if one need them.

Here is the final result of the regexp, don't cry: 
[https://gist.github.com/Pierstoval/eac8d182d2c51c93202f](https://gist.github.com/Pierstoval/eac8d182d2c51c93202f)
