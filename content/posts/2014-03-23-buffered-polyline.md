---
date: "2014-03-23T20:00:00Z"
description: Blow up a polyline to search inside the generated polygon.
tags:
- javascript
- programming
- english
slug: buffered-polyline
title: Buffered Polyline
---

At work, we needed a simple way to buffer a polyline in order to search for stuff along the route from A to B. I'll explain how we used Google's Maps API and [JSTS](https://github.com/bjornharrtell/jsts) in order to achieve this easily.

The first thing we had to do was to "transform" each element in the `overview_path` (which the `DirectionsService` returns) to GeoJSON, because that's what JSTS understands.

{{< highlight javascript "linenos=table" >}}
var overviewPath = response.routes[0].overview_path,
    overviewPathGeo = [];
for(var i = 0; i < overviewPath.length; i++) {
    overviewPathGeo.push(
        [overviewPath[i].lng(), overviewPath[i].lat()]
    );
}
{{< / highlight >}}

The next step was getting `overviewPathGeo` into JSTS and letting it do the work of buffering the line.

{{< highlight javascript "linenos=table" >}}
var distance = 10/111.12, // Roughly 10km
    geoInput = {
        type: "LineString",
        coordinates: overviewPathGeo
    };
var geoReader = new jsts.io.GeoJSONReader(),
    geoWriter = new jsts.io.GeoJSONWriter();
var geometry = geoReader.read(geoInput).buffer(distance);
var polygon = geoWriter.write(geometry);
{{< / highlight >}}

The `polygon` variable now contains a polygon that neatly fits around the `overviewPath`, with a *distance* (buffer size) of roughly 10km.

Since it is nested, you need to call `polygon.coordinates[0]` in order to get back the coordinates of the polygon (as GeoJSON).

You could then use the the coordinates to draw the generated polygon on the map (along with the route), in order to produce something like this:

![Example image of a buffered polyline](/posts/buffered-polyline-1.png)
