---
date: "2016-01-31T17:46:00Z"
description: Description of how to easily anonymize IPs using HAProxy.
tags:
- haproxy
- ops
- english
slug: anonymizing-ips-using-haproxy
title: Anonymizing IPs Using HAProxy
---

At work, I had to come up with an easy way to anonymize the last octet of a logged IP address in order to comply with German data protection laws. If you're using [HAProxy](http://www.haproxy.org) (1.5+), you can do this in one line.

If you want to forward the source IP address to a backend server, you would usually use `option forwardfor`. Sadly you can't set or change the forwarded IP using that option, so instead you have to set the `X-Forwarded-For` header manually.

{{< highlight text >}}
http-request set-header X-Forwarded-For %[src,ipmask(24)]
{{< / highlight >}}

This will set the last octet of the source IP address to zero.

The HAProxy documentation has more information on the various things I used in this post:

* [option forwardfor](https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#4-option%20forwardfor)
* [http-request](https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#4-http-request)
* [src sample](https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#7.3.3-src)
* [ipmask converter](https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#7.3.1-ipmask)
