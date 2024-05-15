## ATS scenery towns

This repository offers the coordinates of scenery towns in ATS.
It was created in order to allow the
[ATS Slippy Map](https://forum.scssoft.com/viewtopic.php?t=318267)
by [**@truckermudgeon**](https://github.com/truckermudgeon)
to add an extra layer showing scenery towns.

Initially, town positions were recorded manually using the game's
"bugs.txt" feature. The result was placed into subdirectories in this
repository, sorted by state.

As of early 2024, there is a plan to base this dataset largely on
mileage target data. The goal is to improve the efficiency of creating
and maintaining the dataset.
See [ATS slippy map ideas](https://gist.github.com/nautofon/d6b3fb841f632478c6db6f0d7f00231e/6027e27045464cfc0409ad144541f6d5f8e19d5e#mileage-targets).

Going forward, the subdirectories will no longer be systematically
maintained. The `all-towns.geojson` file, which is used by Trucker
Mudgeon's map, will be the only supported output format. The
subdirectories will eventually disappear from the `main` branch.
They are archived in the `towns-txt` branch.

### Criteria for scenery towns

A "scenery town" in ATS is defined for this repository as any location
which is not a marked city on the in-game world map and which meets both
of the following criteria:

- Buildings exist in the game world.  
  *Any kind of buildings will do, even commercial or abandoned ones.*

- The place name exists in the game world.  
  *This usually means the exact name must appear on a green road sign.
  Any deducing of place names from e.g. building names or other indirect
  sources should be avoided, except where the situation is super obvious.*

Additionally, the following locations are included if named because of their
navigational value, even where no buildings exist:

- Highway junctions
- Mountain passes

I'm absolutely open to discuss changes to these criteria. The
[ATS Slippy Map thread](https://forum.scssoft.com/viewtopic.php?t=318267)
might be the best place to have such a discussion. Feel free to tag me there
(`@nautofon`).

### Future work

At least mountain passes should probably be in another dataset instead of
this one. They might be removed here if such a dataset becomes available
separately in future.

Beyond that, it might be interesting to expand this idea to other POIs,
such as historical markers, rest areas, or viewpoints.
