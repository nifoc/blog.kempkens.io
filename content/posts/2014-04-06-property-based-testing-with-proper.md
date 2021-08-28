---
date: "2014-04-06T20:15:00Z"
description: Property-based testing in Erlang, with some basic usage examples.
tags:
- erlang
- quickcheck
- testing
- programming
- english
slug: property-based-testing-with-proper
title: Property-based Testing with PropEr
---

[PropEr](http://proper.softlab.ntua.gr/) is a [QuickCheck](https://en.wikipedia.org/wiki/QuickCheck)-inspired property-based testing tool for Erlang. In contrast to traditional testing methodologies, the tester only has to provide the generic structure of valid inputs and some properties, which specify the relation between input and output. The testing tool will then produce progressively more complex valid inputs and compare the results it gets to what it expected (based on the defined properties).  
PropEr is one such testing tool for Erlang. It is [open-source](https://github.com/manopapad/proper) and supports Erlang R15B01+.

Assuming you already have your `$ERL_LIBS` set up, you can simply run the following commands to install PropEr and make it available *globally*.

{{< highlight bash "linenos=table" >}}
cd $ERL_LIBS
git clone git://github.com/manopapad/proper.git
cd proper
make fast
{{< / highlight >}}

After that, you can use PropEr in *all* your Erlang projects.

I like using [EUnit](http://www.erlang.org/doc/apps/eunit/chapter.html) as the runner for my property based tests. There are [some caveats](https://github.com/manopapad/proper#using-proper-in-conjunction-with-eunit), but all in all it works without any issues.  
What I don't like is defining my property-based tests in the same module as my unit tests, because it feels wrong to do so. I generally define one `_test_` function that calls `proper:module/2`.

{{< highlight erlang "linenos=table" >}}
proper_module_test_() ->
  {timeout, 180, ?_assertEqual([], proper:module(example_utils_prop, [long_result, {to_file, user}]))}.
{{< / highlight >}}

This allows me to have all of the unit tests in `example_utils_test` and all of the property-based tests in `example_utils_prop`.

Let's write a simple property-based test for the `binary_join` function I've [introduced in February]({{ site.url }}/posts/joining-a-list-of-binaries-in-erlang/).

{{< highlight erlang "linenos=table" >}}
prop_binary_join() ->
  ?FORALL({Bs, S}, {list(binary()), binary()}, begin
    ExpectedLength = if
      length(Bs) =:= 0 -> 0;
      length(Bs) =:= 1 -> byte_size(hd(Bs));
      true -> lists:foldr(fun(B, Acc) -> byte_size(B) + Acc end, 0, Bs) + ((length(Bs) - 1) * byte_size(S))
    end,
    ExpectedLength =:= byte_size(example_utils:binary_join(Bs, S))
  end).
{{< / highlight >}}

This will test if the size of the output of `example_utils:binary_join/2` is what we would expect:

* Zero: If the list of binaries to join is empty
* Size of the first element in the list: If the list of binaries to join only has one element
* Sum of the size of all elements in the list, plus the size of the separator times the number of elements (minus one, because there will be no trailing separator): All other cases

The `?FORALL` macro takes three aguments:

1. Tuple of variables which will be set to the genrerated inputs and can be accessed in the property
2. Tuple of type specifications for the inputs that will be generated
3. The property that will be tested

If you actually run the test, the output will look something like this:

{{< highlight text >}}
Testing example_utils_prop:prop_binary_join/0
....................................................................................................
OK: Passed 100 test(s).
{{< / highlight >}}

By default, PropEr will generate 100 random valid inputs and compare the output to the (length) properties we defined above.

PropEr can do much more than what I've shown here. While there are not many examples available, you should be able to get going using the documentation.

* [Documentation](http://proper.softlab.ntua.gr/doc/)
* [User Guide](http://proper.softlab.ntua.gr/User_Guide.html)
* [FAQ](http://proper.softlab.ntua.gr/FAQ.html)
* [Tutorials](http://proper.softlab.ntua.gr/Tutorials/)
* [Tips](http://proper.softlab.ntua.gr/Tips.html)
