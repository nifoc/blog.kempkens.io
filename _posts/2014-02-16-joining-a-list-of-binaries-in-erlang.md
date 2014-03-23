---
layout: post
title: Joining a List of Binaries in Erlang
description: "Description and implementation of a function that joins a list of binaries."
category: posts
tags: [erlang, programming, english]
image:
  feature: abstract-3.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
comments: true
share: true
---

The binary module in Erlang provides an easy way to split binaries using `split/2,3`, but what if you want to join a list of binaries back together?

There is no built-in function to do this, so I've decided to write my own.

{% highlight erlang linenos %}
-spec binary_join([binary()], binary()) -> binary().
binary_join([], _Sep) ->
  <<>>;
binary_join([Part], _Sep) ->
  Part;
binary_join(List, Sep) ->
  InitAcc = hd(List),
  lists:foldr(fun (Value, Acc) -> <<Acc/binary, Sep/binary, Value/binary>> end, InitAcc, tl(List)).
{% endhighlight %}

It works just like you would expect:

{% highlight erlang %}
binary_join([<<"Hello">>, <<"World">>], <<", ">>) % => <<"Hello, World">>
binary_join([<<"Hello">>], <<"...">>) % => <<"Hello">>
{% endhighlight %}

Hope you find this useful!
