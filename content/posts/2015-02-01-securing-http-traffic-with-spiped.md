---
date: "2015-02-01T20:59:00Z"
description: Explanation of how to use spiped to encrypt HTTP traffic to backend systems.
tags:
- spiped
- nginx
- ops
- english
slug: securing-http-traffic-with-spiped
title: Securing HTTP Traffic with spiped
---

[spiped](http://www.tarsnap.com/spiped.html) - the secure pipe daemon - is a utility for creating symmetrically encrypted and authenticated pipes between socket addresses. I recently used it to encrypt HTTP traffic from my main webserver to a Raspberry Pi that I run at home.

The spiped utility is available in the [FreeBSD ports tree](http://www.freshports.org/sysutils/spiped/) and package repositories for various Linux-based operating systems. As long as you have a POSIX compliant OS, you should be able to compile it from source, too.

I'm using [nginx](http://nginx.org) on the main webserver and the Raspberry Pi, but (apart from the configuration examples) nothing in this post is nginx specific. All I'm ultimately doing is proxying HTTP traffic to a backend. In my case that backend happens to be another nginx installation, running on a Raspberry Pi.

After installing spiped, the first thing you have to do is to create a (private) key. I ran the following command on my webserver:

{{< highlight bash >}}
dd if=/dev/urandom bs=32 count=1 of=/usr/local/etc/nginx/certs/spiped.key
{{< / highlight >}}

After that, the key has to be securely copied to the backend machine. You can - for example - do this using `scp`. I copied it to `/etc/nginx/certs/spiped.key`, but your paths may vary.

That's it. You can now start spiped.

{{< highlight bash >}}
spiped -D -e -s [127.0.0.1]:9080 -t rpi.kempkens.io:9080 -k /usr/local/etc/nginx/certs/spiped.key
{{< / highlight >}}

That command tells spiped to listen on `127.0.0.1:9080`, encrypt the incoming data and send it to `rpi.kempkens.io:9080`.

To set up the receiving end of the pipe, you have to run something like this:

{{< highlight bash >}}
spiped -D -d -s [0.0.0.0]:9080 -t [127.0.0.1]:80 -k /etc/nginx/certs/spiped.key
{{< / highlight >}}

spiped will listen for incoming connections on port 9080, decrypt the data it receives and forward it to `127.0.0.1:80`.

And that's it.

On the main webserver I have defined an `upstream` that forwards traffic to `127.0.0.1:9080`.

{{< highlight nginx >}}
upstream rpi {
  server 127.0.0.1:9080;
}
{{< / highlight >}}

The nginx installation on the Raspberry Pi listens on port 80, so there is nothing special you have to set up there. It will simply receive the decrypted HTTP traffic from spiped. The only thing that you have to keep in mind is that the server name (`Host`-header) has to be the same on the main webserver and the Raspberry Pi.

An example of how to protect `sshd` using spiped can be found [here](http://www.daemonology.net/blog/2012-08-30-protecting-sshd-using-spiped.html).
