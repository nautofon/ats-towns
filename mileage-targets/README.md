## Distance sign mileage targets

ATS 1.47

This data is read directly from the game files.
The file `def.scs/def/sign/mileage_targets.sii` provides the list of targets,
but most targets only have a node UID instead of the target's position.
Resolving a list of node UIDs to positions is possible using the
[**ts-map**](https://github.com/dariowouters/ts-map) ATS map renderer.

Note that the positions of many mileage targets are intentionally wrong.
Since SCS only uses them for the distance signs, they can get away with
simply adding a fixed "distance offset" to the calculated distance to a target.
But when you actually plot the targets on a map, you will see that some
targets are not positioned where they should be geographically.
Even when the distance offset is zero, the position may not be accurate.
These situations are not always obvious.

Note also that not every mileage target represents a scenery town, while
some scenery towns don't have a mileage target. This data can be a valuable
aid, but it cannot replace the manual search for scenery towns.

### Examples of inaccurate positions

One example of a target not quite in the correct position would be Julesburg,
Colorado. In the ATS world, this town is located north of the interstate at
least one mile from the exit (probably even a bit more, considering the world
scale).

However, as you can see in the screenshot below, the road through the town is
not accessible (as of version 1.47). It has yellow XXX blockers. The road just
before those blockers is the closest node on the ATS road network, and this
seems to be what the node UID in the mileage targets data is referring to.
This is a pattern you see frequently in the mileage targets file.

In the case of Julesburg, the distance offset happens to be zero, which is
arguably a bug. Many similar cases have a positive distance offset to
account for the distance between the node and the target, e.g. Wheatland,
Wyoming. (That said, distance signs were never meant to be *exactly*
accurate anyway; see
[**natvander**'s explanation](https://forum.scssoft.com/viewtopic.php?t=300959&start=170#p1600632).
Reporting this "bug" would likely only waste people's time.)

In a few extreme cases, the distance offset reaches 100 miles (often for
locations not yet included in ATS, e.g. Springfield, Colorado in 1.47).
Some cases with a *negative* offset exist as well (e.g. Denver, Colorado),
as do a number of other oddities (such as Houston, Texas, which in 1.47
is defined by position rather than by node UID, but which for some reason
still has a non-zero distance offset).

![](https://raw.githubusercontent.com/nautofon/ats-towns/main/mileage-targets/example-julesburg.jpg)
