---
layout: post
title: OCSP Stapling with nginx
description: "A general explanation of how to set up OCSP stapling with nginx."
date: 2014-03-30 21:30:00 CEST
modified: 2015-08-03 20:55:00 CEST
category: posts
tags: [nginx, ocsp, ssl, ops, english]
comments: true
---

Setting up [OCSP stapling](https://en.wikipedia.org/wiki/OCSP_stapling) with [nginx](http://nginx.org/) is more or less straightforward, but depending on what's in your `ssl_certificate` you might run into some issues with it silently failing. So I've decided to write about how I set up OCSP stapling with certificates from [StartSSL](https://www.startssl.com/) and [CAcert](http://www.cacert.org/).

I have only tested this using nginx version 1.5.12, but the configuration options I'm using have been in nginx since version 1.3.7. If it does not work for some reason, feel free to leave a comment below.

To enable OCSP stapling, you simply have to add the following lines to your (already SSL enabled) site:

{% highlight nginx %}
resolver                   8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220 valid=300s;
resolver_timeout           10s;

ssl_stapling               on;
ssl_stapling_verify        on;
ssl_trusted_certificate    /etc/nginx/certs/startssl.stapling.crt;
{% endhighlight %}

The important thing here is the usage of `ssl_trusted_certificate`. The [nginx documentation](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_stapling_verify) states that:

> For verification to work, the certificate of the server certificate issuer, **the root certificate, and all intermediate certificates** should be configured as trusted using the ssl_trusted_certificate directive.

You have to include the root certificate (and intermediate certificates) for OCSP stapling to work, which is why `ssl_trusted_certificate` will be set to a *special* certificate file that includes those. If your `ssl_certificate` already does, you might be able to skip using `ssl_trusted_certificate`.

## CAcert

For CAcert (and unless you have a Class 3 certificate) you only have to include the Class 1 certificate in your stapling file.

{% highlight text %}
03/08/2015 Removed. Get the Class 1 certificate here: http://www.cacert.org/index.php?id=3
{% endhighlight %}

## StartSSL

StartSSL - using a Class 1 certificate again - has an intermediate certificate in their chain, so you have to include this one in your stapling file, too.

{% highlight text %}
03/08/2015: Removed. Get the root certificate and the intermediate certificate here: https://www.startssl.com/certs/
{% endhighlight %}

After you've done all that, you can restart nginx or reload the configuration and you should be good to go!

You can verify that everything works using the `openssl` command line tool.

{% highlight bash %}
openssl s_client -servername blog.kempkens.io -connect blog.kempkens.io:443 -tls1 -tlsextdebug -status
{% endhighlight %}

Both of those should include a section (with data) named "OCSP Response Data".

An alternative way to test if OCSP stapling is supported, is by using [Qualys SSL Labs](https://www.ssllabs.com/ssltest/).

Keep in mind that nginx does not include OCSP data in the first response, because it has to fetch it, too. So you probably have to try at least two times to verify if it works or not.

**Update #1**

If you have more than one virtual host with SSL enabled, you have to enable OCSP stapling for every single one. Otherwise nginx will fail silently and not include any stapled OCSP data. (Thanks to [@rmoriz](https://roland.io) for figuring this out)

**Update #2**

This post has been quite popular, so I decided to update it a little bit. The biggest change is that I have removed the certificate chains that were originally included in this post. I did this to not confuse people too much and because I don't want to keep these chains up to date.

The most important thing to remember when setting up OCSP stapling with any CA is to make sure that the entire trust chain (including the root certificate) is included in the `ssl_trusted_certificate` file.
