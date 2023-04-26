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
