---
date: "2014-04-12T21:25:00Z"
description: Short description of how to install Erlang/OTP 17.0 using kerl on Mac OS X.
tags:
- erlang
- programming
- english
slug: installing-erlang-17-0-using-kerl
title: Installing Erlang 17.0 On Mac OS X
---

It's been a few days since [Erlang/OTP 17.0](http://www.erlang.org/news/73) has been released. Installing 64 Bit Erlang (with [Observer](http://www.erlang.org/doc/man/observer.html) support) on Mac OS X has always been a bit tricky, but with 17.0 it has gotten significantly easier.

First you need to install/get some prerequisites:

* [Command Line Tools for Xcode](https://developer.apple.com/downloads) or [Xcode](http://itunes.apple.com/us/app/xcode/id497799835)
* [Homebrew](http://brew.sh)
* [kerl](https://github.com/spawngrid/kerl)

After you've gotten these three, we start by installing *wxWidgets*. It's required in order to use the Observer GUI.

{{< highlight bash >}}
brew install wxmac
{{< / highlight >}}

Compiling *wxWidgets* might take some time. After it's done, you should create a `~/.kerlrc` file. It's basically a configuration file for *kerl*, which will be used for every Erlang version you compile. You can find the list of available options in the [*kerl* readme](https://github.com/spawngrid/kerl#tuning). Mine looks like this:

{{< highlight bash "linenos=table" >}}
CPPFLAGS="-march=native -mtune=native -O3 -g"
KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-smp-support --enable-threads --enable-hipe --enable-kernel-poll --enable-darwin-64bit --with-wx"
KERL_DEFAULT_INSTALL_DIR="$KERL_BASE_DIR/installs"
{{< / highlight >}}

We can now move on to actually installing Erlang/OTP 17.0.

{{< highlight bash >}}
kerl update releases
kerl build 17.0 17.0
kerl install 17.0 17.0
{{< / highlight >}}

After the installation is finished, *kerl* will output instructions on how to enable a specific Erlang version globally. In general, you will put something like the following in your `~/.zshrc` or `~/.bash_profile`:

{{< highlight bash >}}
source $HOME/.kerl/installs/17.0/activate
{{< / highlight >}}

The following `alias` makes it easier to start the Observer from a terminal. The only command you have to remember is `erlobserver`.

{{< highlight bash >}}
alias erlobserver='erl -sname observer -run observer -detached'
{{< / highlight >}}

![Image of a running Observer instance](/posts/installing-erlang-17-0-using-kerl-1.png)
