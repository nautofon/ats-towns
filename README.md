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
bug reporting feature.
That dataset has been removed from this branch. It's been archived on the
[`towns-txt`](https://github.com/nautofon/ats-towns/tree/towns-txt) branch,
along with some documentation and tools that probably are no longer relevant.

### Usage

> [!IMPORTANT]  
> At time of this writing, the review of the `extra-labels` generator is
> ongoing. To actually run the generator, you may need to check out the
> [`extra-labels`](https://github.com/nautofon/maps-nodejs/tree/extra-labels)
> branch in nautofon's fork. Note that the interface of the generator may end
> up being slightly different in the final merged version.

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
