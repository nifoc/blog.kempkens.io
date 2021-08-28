---
date: "2014-12-24T13:25:00Z"
description: Simple workaround for supporting deprecated types and warnings_as_errors with erlang.mk.
tags:
- erlang
- programming
- english
slug: supporting-deprecated-types-with-erlang-mk
title: Supporting Deprecated Types with erlang.mk
---

In April I wrote about how I use the `platform_define` feature of [rebar](https://github.com/rebar/rebar) to make deprecated types work without removing `warnings_as_errors`. I have switched to [erlang.mk](https://github.com/ninenines/erlang.mk) since then, but needed a similar feature for [one of my libraries](https://github.com/nifoc/noesis).

Since erlang.mk only uses [make](http://en.wikipedia.org/wiki/Make_(software)), adding support for a `platform_define`-like feature is very straightforward.

{{< highlight makefile >}}
otp_release = $(shell erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), init:stop()')
otp_17plus = $(shell echo $(otp_release) | grep -q -E "^[[:digit:]]+$$" ; echo $$?)
{{< / highlight >}}

The first variable (`otp_release`) will contain the OTP version (e.g. `17`). The second variable (`otp_17plus`) will be either `0` or `1`, depending on wether or not `otp_release` matches a regular expression. The regular expression checks if `otp_release` is just a number (e.g. `17`) or not (e.g. `R16B03-1`).

That's enough to conditionally add options to `erlc`.

{{< highlight makefile >}}
ifeq ($(otp_17plus),0)
	ERLC_OPTS += -Dnamespaced_types=1
	TEST_ERLC_OPTS += -Dnamespaced_types=1
endif
{{< / highlight >}}

This will define `namespaced_types` only on Erlang 17+, allowing us to use the same `ifdef`-switch from April.

{{< highlight erlang "linenos=table" >}}
-ifdef(namespaced_types).
-type xxx_dict() :: dict:dict().
-else.
-type xxx_dict() :: dict().
-endif.
{{< / highlight >}}
