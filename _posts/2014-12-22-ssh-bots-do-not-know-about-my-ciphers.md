---
layout: post
title: SSH Bots Don't Know about My Ciphers
description: "Choosing a small number of newer ciphers prevents SSH bots from connecting."
date: 2014-12-22 19:45:00 CET
category: posts
tags: [ssh, ops, english]
comments: true
---

Last weekend I decided to update my `sshd_config` to include a very limited set of ciphers, MACs and key exchange algorithms. I did this to tighten the security of my `sshd` and not because I wanted to prevent bots from trying (and failing) to log in to my servers. I'm already using [fail2ban](http://www.fail2ban.org) for that.  
However, after I updated my configuration I noticed failed login attempts basically dropped to zero, because all these bots do not support my very restrictive set of ciphers.

{% highlight text %}
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
{% endhighlight %}

In order to use these settings, you need a recent version of [OpenSSH](http://www.openssh.com). I'm running 6.6 locally and on my servers, the minimum version that supports these settings is 6.4.

After these changes your `auth.log` will probably contain this line rather often:

{% highlight text %}
fatal: no matching cipher found: client aes128-ctr,aes192-ctr,aes256-ctr,aes256-cbc,rijndael-cbc@lysator.liu.se,aes192-cbc,aes128-cbc,blowfish-cbc,arcfour128,arcfour,cast128-cbc,3des-cbc server chacha20-poly1305@openssh.com,aes256-gcm@openssh.com [preauth]
{% endhighlight %}

Please keep in mind that this will not prevent bots from attacking you (in the future) and that you have to mitigate these attacks by other means. I only wrote this post because I thought it was kind of interesting that SSH bots do not support these settings *right now*.
