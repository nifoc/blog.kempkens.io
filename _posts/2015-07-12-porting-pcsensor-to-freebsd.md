---
layout: post
title: Porting pcsensor to FreeBSD
description: "Introducing my port of the pcsensor utility to FreBSD."
date: 2015-07-12 18:46:00 CEST
category: posts
tags: [pcsensor, freebsd, english]
comments: true
---

Last week, it got rather hot where I live and so I got interested in measuring the temperature of the room where I keep my NAS and various other devices. I started looking for cheap USB thermometers and quickly found [this one](http://www.amazon.de/gp/product/B009RETJIO). It has some decent reviews and costs only around 16€, which seemed perfect to simply play around with.

The device only comes bundled with Windows software, but there is an open source utility called `pcsensor` which allows you use it via the command line on Linux. I don't have any Linux devices in the room that I wanted to measure. Since the source code was pretty straightforward and only minimal changes were required to port the utility to FreeBSD, I did just that! You can find the ported source code on [GitHub](https://github.com/nifoc/pcsensor-freebsd).

{% highlight text %}
$ pcsensor -h
pcsensor version 1.0.3
      Aviable options:
          -h help
          -v verbose
          -l[n] loop every 'n' seconds, default value is 5s
          -c output only in Celsius
          -f output only in Fahrenheit
          -a[n] increase or decrease temperature in 'n' degrees for device calibration
          -m output for mrtg integration
          -d output with Bus and Device number
          -D display device list
          -D[n] specific device number
{% endhighlight %}

If you want to read the temperature from the device, you might have to prefix the call to `pcsensor` with `sudo`.
