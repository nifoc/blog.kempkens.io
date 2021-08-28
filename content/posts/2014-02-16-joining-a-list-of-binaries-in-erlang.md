---
date: "2014-02-16T15:30:00Z"
description: Description and implementation of a function that joins a list of binaries.
tags:
- erlang
- programming
- english
slug: joining-a-list-of-binaries-in-erlang
title: Joining a List of Binaries in Erlang
---

The binary module in Erlang provides an easy way to split binaries using `split/2,3`, but what if you want to join a list of binaries back together?

There is no built-in function to do this, so I've decided to write my own.

{{< highlight erlang >}}
-spec binary_join([binary()], binary()) -> binary().
binary_join([], _Sep) ->
  <<>>;
binary_join([Part], _Sep) ->
  Part;
binary_join([Head|Tail], Sep) ->
  lists:foldl(fun (Value, Acc) -> <<Acc/binary, Sep/binary, Value/binary>> end, Head, Tail).
{{< / highlight >}}

It works just like you would expect:

{{< highlight erlang >}}
binary_join([<<"Hello">>, <<"World">>], <<", ">>) % => <<"Hello, World">>
binary_join([<<"Hello">>], <<"...">>) % => <<"Hello">>
{{< / highlight >}}

Hope you find this useful!
