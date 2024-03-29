---
date: "2014-04-18T20:25:00Z"
description: Simple workaround for supporting deprecated types and warnings_as_errors.
tags:
- erlang
- programming
- english
slug: erlang-17-0-supporting-deprecated-types-without-removing-warnings_as_errors
title: 'Erlang 17.0: Supporting Deprecated Types Without Removing warnings_as_errors'
---

Erlang 17.0 [deprecated some pre-defined types](http://www.erlang.org/download/otp_src_17.0.readme) like `dict()` and `gb_tree()` in favor of `dict:dict()` and `gb_tree:tree()`. The workaround they suggest (`nowarn_deprecated_type`) works in 17.0, but would break once the deprecated types are removed.  
Not using `nowarn_deprecated_type` means that you can't use `warnings_as_errors`, because it would make deprecation warnings an error.

A rather nice solution to this issue an option that [rebar](https://github.com/rebar/rebar) takes: `platform_define`.

>It is also possible to specify platform specific options by specifying a pair or a triplet where the first string is a regex that is checked against the string
>
>  OtpRelease ++ "-" ++ SysArch ++ "-" ++ Words.
>
>where
>
>  OtpRelease = erlang:system_info(otp_release).  
>  SysArch = erlang:system_info(system_architecture).  
>  Words = integer_to_list(8 * erlang:system_info({wordsize, external})).

This allows us to set a `namespaced_types` option on 17.0+ only.

{{< highlight erlang >}}
{erl_opts, [
  {platform_define, "^[0-9]+", namespaced_types},
  debug_info,
  warnings_as_errors
]}.
{{< / highlight >}}

In your source files you can then check if the option is set and define an (internal) type accordingly.

{{< highlight erlang "linenos=table" >}}
-ifdef(namespaced_types).
-type xxx_dict() :: dict:dict().
-else.
-type xxx_dict() :: dict().
-endif.
{{< / highlight >}}

I learned about this trick by looking at how [meck](https://github.com/eproxus/meck) handles Erlang 17.0 support.
