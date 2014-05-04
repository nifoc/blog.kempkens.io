---
layout: post
title: 'Katja: Riemann Client Written In Erlang'
description: "Introductory post about the Riemann client I've written."
date: 2014-05-04 21:55:00 CEST
category: posts
tags: [erlang, programming, riemann, katja, english]
image:
  feature: header/abstract-11.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
comments: true
share: true
---

[Riemann](http://riemann.io) is a network monitoring system written in Clojure, it offers a rather simple [protobuf](https://de.wikipedia.org/wiki/Protocol_Buffers)-based API. I have just tagged [Katja](https://github.com/nifoc/katja) [version 0.1](https://github.com/nifoc/katja/tree/v0.1), my Riemann client written in Erlang.

Katja supports all the basic things a Riemann client has to support. It can ...

- ... send events
- ... send states
- ... query events

Additionally multiple events and states can also be send in a single message.

Katja only supports Erlang/OTP R16B01+. This is mostly because in releases before R16 `query` was an unused keyword, meaning that you could not easily use it as a function name or record field.

## Sending Events

{% highlight erlang linenos %}
Event = [{service, "katja demo"}, {metric, 9000.1}],
ok = katja:send_event(Event),
Event2 = [{service, <<"katja demo">>}, {metric, 9000.1}, {tags, ["demo"]}],
ok = katja:send_events([Event, Event2]).
{% endhighlight %}

Katja allows you to send either a single event or multiple ones. Events are simple property lists with the following (possible) keys: time, state, service, host, description, tags, ttl, attributes, metric.

The entire `katja:event()` type definition can be found on [GitHub](https://github.com/nifoc/katja/blob/v0.1/src/katja.erl#L31..L33).

## Sending States

{% highlight erlang linenos %}
State = [{service, "katja demo"}, {state, "testing"}],
ok = katja:send_state(State),
State2 = [{service, "katja demo"}, {state, "testing"}, {tags, ["demo"]}],
ok = katja:send_states([State, State2]).
{% endhighlight %}

States and events are very similar, so much so that the (possible) keys of a state property list are almost identical to the keys of an event property list: time, state, service, host, description, tags, ttl, once.

Once again, the entire `katja:state()` type definition can be found on [GitHub](https://github.com/nifoc/katja/blob/v0.1/src/katja.erl#L34..L36).

## Querying Events

{% highlight erlang linenos %}
{ok, Events} = katja:query("service = \"katja demo\"").
{% endhighlight %}

`katja:query/1` will return a list of events. Events are a property list of type `katja:event()`, so what you send to Riemann is also what you get back when querying. There is one important thing to keep in mind: All `undefined` or `[]` values will be removed from the returned property list(s).

You can find example queries in the [Riemann test suite](https://github.com/aphyr/riemann/blob/master/test/riemann/query_test.clj).

## Sending Entities

{% highlight erlang linenos %}
Event = [{service, "katja demo"}, {metric, 9000.1}],
State = [{service, "katja demo"}, {state, "testing"}],
ok = katja:send_entities([{events, [Event]}, {states, [State]}]).
{% endhighlight %}

Katja also allows you to send mutiple events and/or states in a single request via `katja:send_entities/1`.

## Future

There are two things I'm currently thinking about adding to Katja:

1. Adding (generic) support process pools: This should be done in a way that does not assume anything about the pool that's being used. Katja will not depend on a specific process pool implementation.

2. Querying based on a property list: This means that you could pass a property list of type `katja:event()` to a query method and get back events based on that. In general, all it should take to do this is transforming the property list in a query string that Riemann understands.
