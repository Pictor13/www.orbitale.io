---
layout: post
title:  "EasyImpress"
date:   2015-12-28 18:48:24 +0200
---

EasyImpress is a PHP application developed with Symfony framework, it allows you to realize beautiful 3D sliders using
the powerful [Impress.js](https://github.com/bartaz/impress.js/) library.
The demonstration is built with [EasyImpressBundle](https://github.com/Orbitale/EasyImpressBundle), which allow you to
write simple configuration and get all the benefits of Impress.js in a simple configuration file.
With a simple [YAML](http://en.wikipedia.org/wiki/YAML) file, you can place all your sliders in the canvas.

{% highlight yaml %}
slides:
   first:
       data:
           x: 0
           y: 0
           z: 0 
   second:
       data:
           x: 500
           y: 500
           z: 500
{% endhighlight %}

Realize simple horizontal transitions

{% highlight yaml %}
config:
  increments:
      x:
          base: 0
          i: 100
{% endhighlight %}

Or more complex canvases!

* [View EasyImpressBundle on Github](https://github.com/Orbitale/EasyImpressBundle), with its documentation.
* [View the demo here](http://demo.orbitale.io/easy_impress/).
