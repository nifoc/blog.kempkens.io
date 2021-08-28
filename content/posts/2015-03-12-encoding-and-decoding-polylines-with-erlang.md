---
date: "2015-03-12T22:03:00Z"
description: Description and implementation of functions that encode and decode polylines.
tags:
- erlang
- programming
- english
slug: encoding-and-decoding-polylines-with-erlang
title: Encoding and Decoding Polylines with Erlang
---

If you have ever worked with the [Google Directions API](https://developers.google.com/maps/documentation/directions/?csw=1) you probably came across [encoded polylines](https://developers.google.com/maps/documentation/utilities/polylinealgorithm). I wanted to decode and encode these using Erlang but was unable to find an existing implementation. So I decided to write my own.

* A single point (latitude/longitude pair) is represented using a tuple
* A path, i.e. a decoded polyline, is represented as a list of point tuples
* An encoded polyline is represented as a simple binary string

{{< highlight erlang >}}
Point = {Lng, Lat},
Path = [{Lng, Lat}, {Lng2, Lat2}].
{{< / highlight >}}

The `encode/1` function takes a path and returns an encoded polyline.

{{< highlight erlang "linenos=table" >}}
encode(Path) -> encode_acc(Path, 0, 0, <<>>).

% Private

encode_acc([], _PLat, _PLng, Acc) -> Acc;
encode_acc([{Lng, Lat}|Rest], PLat, PLng, Acc) ->
  LatE5 = round(Lat * 1.0e5),
  LngE5 = round(Lng * 1.0e5),
  EncodedLat = encode_part(encode_sign(LatE5 - PLat), <<>>),
  EncodedLng = encode_part(encode_sign(LngE5 - PLng), <<>>),
  encode_acc(Rest, LatE5, LngE5, <<Acc/binary, EncodedLat/binary, EncodedLng/binary>>).

encode_sign(Num) when Num < 0 -> bnot (Num bsl 1);
encode_sign(Num) -> Num bsl 1.

encode_part(Num, Result) when Num < 32 -> <<Result/binary, (Num + 63)>>;
encode_part(Num, Result) ->
  Value = (32 bor (Num band 31)) + 63,
  encode_part(Num bsr 5, <<Result/binary, Value>>).
{{< / highlight >}}

The `decode/1` function takes an encoded polyline and returns a path.

{{< highlight erlang "linenos=table" >}}
decode(Line) -> decode_acc(Line, 0, 0, []).

% Private

decode_acc(<<>>, _Lat, _Lng, Acc) -> lists:reverse(Acc);
decode_acc(Line, Lat, Lng, Acc) ->
  {DLat, Rest} = decode_part(Line, 32, 0, 0),
  Lat2 = Lat + DLat,
  {DLng, Rest2} = decode_part(Rest, 32, 0, 0),
  Lng2 = Lng + DLng,
  decode_acc(Rest2, Lat2, Lng2, [{Lng2 / 1.0e5, Lat2 / 1.0e5} | Acc]).

decode_part(Line, B, _Shift, Result) when B < 32 ->
  Result2 = if
    Result band 1 == 0 -> Result bsr 1;
    true -> bnot (Result bsr 1)
  end,
  {Result2, Line};
decode_part(<<C:8, Rest/binary>>, _OldB, Shift, Result) ->
  B = C - 63,
  Result2 = Result bor ((B band 31) bsl Shift),
  decode_part(Rest, B, Shift + 5, Result2).
{{< / highlight >}}

I have written these functions for [noesis](https://github.com/nifoc/noesis), which is a library that contains useful utility functions. Right now the implementation is only available in the [development branch](https://github.com/nifoc/noesis/blob/development/src/noesis_polyline.erl). It is tested using [EUnit](https://github.com/nifoc/noesis/blob/f3e9ae21d53e09bea9ca48fe4a56ddd006952e0a/test/noesis_polyline_test.erl) and [QuickCheck](https://github.com/nifoc/noesis/blob/f3e9ae21d53e09bea9ca48fe4a56ddd006952e0a/test/noesis_polyline_triq.erl).

If you're reading this a couple of months from now, you might find an updated implementation on GitHub.
