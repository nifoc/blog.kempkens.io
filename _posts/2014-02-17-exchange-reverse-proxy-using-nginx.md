---
layout: post
title: Exchange Reverse Proxy Using nginx
description: "Simple nginx configuration that allows you to proxy most of Microsoft Exchange."
date: 2014-02-17 21:45:00 CET
category: posts
tags: [nginx, exchange, ops, english]
image:
  feature: header/abstract-10.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
comments: true
share: true
---

As it turns out, setting up [nginx](http://nginx.org) as a reverse proxy for Microsoft Exchange is not as easy as [some](http://blog.friedlandreas.net/2013/07/reverseproxy-fur-eas-exchange-activesync-und-owa-outlookwebapp-mit-nginx/) [posts](http://www.administrator.de/wissen/ngnix-als-reverse-proxy-für-exchange-2010-192711.html) suggest.

The issue that for some calls (Autodiscovery, RPC, …) IIS asks for an `Authorization` header, which nginx can pass through by doing:

{% highlight nginx %}
proxy_pass_header Authorization;
{% endhighlight %}

Only problem is: It doesn't work. Thankfully someone on StackOverflow already had a [solution](http://stackoverflow.com/a/19714696) for this:

{% highlight nginx %}
proxy_http_version 1.1;
proxy_pass_request_headers on;
proxy_pass_header Date;
proxy_pass_header Server;

proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
more_set_input_headers 'Authorization: $http_authorization';
proxy_set_header Accept-Encoding "";
more_set_headers -s 401 'WWW-Authenticate: Basic realm="your.mail.host"';
proxy_pass https://your.mail.host;
{% endhighlight %}

You'll need the [HttpHeadersMore](http://wiki.nginx.org/HttpHeadersMoreModule) module for this to work. On Ubuntu 12.04 (using the [nginx/stable PPA](https://launchpad.net/~nginx/+archive/stable)) all you need to install is:

{% highlight bash %}
apt-get install nginx-extras
{% endhighlight %}

And you're good to go!
