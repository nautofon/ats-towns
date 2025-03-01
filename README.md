## ATS map label metadata

This repository offers metadata that refines map labels generated from
[ATS](https://americantrucksimulator.com/) mileage targets.
The metadata is designed to be used with the `extra-labels` generator in
**Trucker Mudgeon**'s [TruckSim Maps](https://github.com/truckermudgeon/maps)
project.

Mileage targets for ATS are fairly homogeneous when it comes to towns:
Most ATS settlements have mileage targets, and few named mileage targets
represent destinations that aren't settlements. By filtering unnamed
targets and marked cities heuristically, the `extra-labels` generator can
produce tolerable map labels for scenery towns even without any metadata.
It can optionally use the metadata offered here to improve its results.

The primary focus of this metadata is currently scenery towns.
But the game contains a lot of named features other than towns.
The scope of the dataset may eventually be expanded beyond towns.

This repository was created in order to allow the
[ATS Slippy Map](https://forum.scssoft.com/viewtopic.php?t=318267)
to add an extra layer showing scenery towns.
Initially, town positions were recorded manually using the game's
"bugs.txt" feature. The result was placed into subdirectories in this
repository, sorted by state.

Going forward, the subdirectories will no longer be systematically
maintained. The `all-towns.geojson` file, which is used by Trucker
Mudgeon's map, will be the only supported output format. The
subdirectories will eventually disappear from the `main` branch.
They are archived in the `towns-txt` branch.

### Usage

To use this metadata, you first need to apply it to the game's
mileage targets dataset in the manner explained in the
[Label Metadata Description](label-metadata.md).
One way to do that is with the `extra-labels` generator in Trucker Mudgeon's
[TruckSim Maps](https://github.com/truckermudgeon/maps) project.

```sh
# Convert metadata CSV into JSON and generate map labels GeoJSON
# for display on Trucker Mudgeon's ATS Map
script/csv2json.pl US/*.csv > ../maps/usa-labels-meta.json
cd ../maps
npx generator extra-labels --meta usa-labels-meta.json \
  -i dirWithParserOutput -o ../ats-towns

# Generate metadata CSV template from ATS mileage targets
# for a single state (e.g. newly released DLC)
npx generator extra-labels --json --no-meta \
  -i dirWithParserOutput -o ../ats-towns
cd ../ats-towns
script/json2csv.pl extra-labels.json --country US-NE > US/US-NE.csv
```

### Author

Created and maintained by **nautofon**.

Feedback, issue reports, and other contributions are welcome.
Please post any comments or questions in Trucker Mudgeon's SCS forum thread
["A Slippy Map for ATS"](https://forum.scssoft.com/viewtopic.php?t=318267).
(Or send a PM to `nautofon`, if you prefer.)
