# Label Metadata Description

The label metadata is meant to be used together with mileage targets.

Label metadata may contain the following attributes for each label.
They are described in detail further down in this document.
All attributes are optional.

- [`token`](#token)
- [`text`](#text)
- [`easting`](#easting--southing)
- [`southing`](#easting--southing)
- [`kind`](#kind)
- [`signed`](#signed)
- [`access`](#access)
- [`industry`](#industry)
- [`city`](#city)
- [`country`](#country)
- [`show`](#show)
- [`checked`](#checked)
- [`ref`](#ref)
- [`remark`](#remark)

**Attributes are missing** in cases where information garnered from analyzing
mileage targets should be used instead if available, for example because the
location in question has yet to be manually assessed for its metadata.

**Attributes are undefined** in cases where the location *has* been
assessed, but the correct value couldn't be determined.
This is primarily an internal distinction, used to control how this
metadata is merged with the mileage targets dataset. For most data users,
the difference between missing and undefined attributes won't matter.

<!--
In practice, unassessed labels will be relatively common in this dataset.
-->

## Serialization

Label metadata can be serialized as a [CSV](https://datatracker.ietf.org/doc/html/rfc4180)
table. They should have a header row and should avoid line breaks inside
fields. Ordering the columns in the same order in which the attributes are
defined in this document is recommended.

```csv
token,text,easting,southing,kind,signed,access,industry,city,country,show,checked,ref,remark
wy_yellowsth,,-58854,-37767,nature,all,"yes",~,jackson,US-WY,no,2025-02,,ST drop-off only
...
```

Empty fields signify missing values, fields containing only `~` undefined
values. For boolean attributes, a match on `/^no?\b/i` is to be interpreted
falsy, any other string truthy; but when *writing* CSV, booleans should be
coded as `yes` and `no`.

<!--
The description has the flexibility to add micro-formats or comments to
booleans in future. The chance that I'll actually use this is fairly slim.
But it's much easier to allow for that now and perhaps remove the
flexibility later if it's not needed, rather than to bolt it on later
and having to worry about interoperability.
-->

Alternatively, label metadata can be serialized as objects in a
[JSON](https://datatracker.ietf.org/doc/html/rfc8259) array.
Attributes with an undefined value are coded as `null`.

```json
[
  {
    "token"    : "wy_yellowsth",
    "easting"  : -58854,
    "southing" : -37767,
    "kind"     : "nature",
    "signed"   : "all",
    "access"   : true,
    "industry" : null,
    "city"     : "jackson",
    "country"  : "US-WY",
    "show"     : false,
    "checked"  : "2025-02",
    "remark"   : "ST drop-off"
  },
  ...
]
```

For consistency, the preferred order of records in both cases is to sort
ascending by `country` and by `text`.
Records without country code should instead come last, sorted by `token`.
Within each country, records with `kind = unnamed` should always come last.

<!--
It's admittedly a bit convoluted, but it seems to work well in practice
during editing.
-->

## Attributes

### token

    token: string

The "token" identifying the mileage target to apply the label attributes to.

**If missing or undefined,** this record describes a new label instead
of refining an existing one. In this case, position and label text
should be present, so as to be able to show the label on a map.

A [token](https://modding.scssoft.com/wiki/Documentation/Engine/Units#Attribute_types)
is a string-like ID used by SCS that can be encoded in a single 64-bit value.
The concept is similar to [OSType](https://en.wikipedia.org/wiki/FourCC#Technical_details)
known from classic Mac OS, but restricts the available characters [`a-z0-9_`]
in order to allow a human-readable representation of up to 12 chars in length.

### text

    text: string

The text for this label.

The label text should generally be decided upon using the same principles
that OpenStreetMap uses for determining a feature's
[primary name](https://wiki.openstreetmap.org/wiki/Key:name#Values):
Favor the situation "on the ground", but allow for common sense.
Names should be written as they appear on signs, in the local language.
If signs in the game world abbreviate a name, but the name can reasonably
be spelled out in full, the `text` should also be spelled out in full.
However, if the full name is quite unwieldy or even obscure in the real
world, abbreviating it may sometimes be better after all.
The `remarks` attribute may be used to write down the rationale.

<!--
For example, the search feature in web maps should probably show and accept
the full name, even when the name shown on the map itself is abbreviated.
-->

### easting / southing

    easting: number
    southing: number

The *adjusted* position for this label, if any.

Many labels will use the position included with a mileage target. These
attributes should only be present in the metadata in cases where the mileage
target position is inadequate; otherwise, they should be missing.

<!--
For software that doesn't have good support for south-oriented coordinate
systems, a `northing` attribute may be used instead of or in addition to
`southing`. These attributes differ only in the sign. In order to make
interoperability easier, `northing` shouldn't be used for data exchange.
-->

### kind

    kind: string

The kind of location this label is for. Possible values include (but are not
necessarily limited to) the following:

* `city`: Marked city, e.g. Bakersfield, CA.
* `town`: Unmarked scenery town, urban district, or other settlement, e.g. Buttonwillow, CA.
* `hamlet`: Like `town`, but *tiny*, e.g. Hiland, WY.
* `bridge`: Notable bridge, e.g. Golden Gate Bridge, CA.
* `tunnel`: Notable tunnel, e.g. Collier Tunnel, CA.
* `pass`: Mountain pass, e.g. Crestwood Summit, CA.
* `junction`: Named but unpopulated intersection, e.g. Muddy Gap, WY.
* `port`: Unpopulated ferry port, e.g. Port Bolivar, TX.
* `dam`: Notable dam or reservoir, e.g. Broken Bow Dam, OK.
* `parking`: Named turnout, wayside, scenic overlook, or other parking area (may or may not have sleep functionality), e.g. Snake River Picnic Area, WY.
* `historic`: Location of historic significance, e.g. Nebraska Prairie Museum.
* `nature`: Notable park, forest or other natural feature, e.g. Hell's Half Acre, WY.
* `military`: Military or similar restricted zone, e.g. Yuma Proving Ground, AZ.
* `unnamed`: Mileage target location with no name, e.g. "US-160 x US-183", KS.
    Mileage targets without a name are generally unusable as map labels and
    should be filtered out by data users.

<!--
Possible additions:
* `area`: Indian reservation etc. (but, like forests: generally don't include them; signs are sporadic and roads often meander in and out of them, so it's difficult to keep track of)
* `industrial`: Named industrial site (are there any? SCS tends to avoid such names)

Differentiations:
- `hamlet`: smaller than a town, tiny number of houses, often no infrastructure; maybe the cut-off is at around 6 houses or so
- parking vs. nature location: the importance of the nature location is a factor; e.g. Beaver Rim WY is `parking`, Hell's Half Acre WY is `nature` (it's subjective though)
-->

This dataset doesn't claim to be complete, *especially* not for locations
that aren't scenery towns.
Some of these categories exist only because they show up in mileage target data.
The list of values used as `kind` may change in future, depending on which
locations SCS will use as mileage targets and the needs of metadata users.

### signed

    signed: stringy enumeration

Describes how the name is signed at a location in the game.

A scenery town often has a green road sign at the town limit bearing the name.
Some instead have non-official or artistic installations showing the town name;
if these are well readable, they should be considered the same as a road sign.
For other kinds of locations than towns, the same principle applies.
Possible values are the following:

* `all`: Name well visible, no matter which direction you arrive from; e.g. San Lucas, CA.
* `most`: Name well visible when arriving from a clear majority of directions; e.g. Hoback Jct, WY.
* `some`: Name visible in *some* way, but it may not be very obvious; e.g. Five Points, CA.
* `remote`: Name *not* visible on site, but it appears on distance / direction signs elsewhere; e.g. Kerman, CA.

Locations that aren't named within the game world at all probably shouldn't be
labeled on the map. If labels for such locations are included in this dataset
anyway, they should be coded as `kind = "unnamed"` and `signed = undefined`.

### access

    access: boolean

Whether or not a core part of the named location is accessible during
regular gameplay.

Typically, locations are accessible where you can drive past the sign
stating the location's name, or where you can drive onto a parking
area or turnout dedicated for visitors of the location in question.
But there are exceptions, for example where the only road is a
freeway and there are no usable exits to the location.
If there is no sign, the same principle is applied, but with respect
to the point where you would normally expect the sign to be.

<!--
Many non-town locations are unreachable by nature, for example natural
features: You can't drive a vehicle off-road. To avoid `access` being
entirely meaningless for such locations, the ability to access dedicated
parking should be considered instead. Such a parking area is effectively
the "core" of the feature as far as road users are concerned.
-->

In some cases, assessing this attribute will require some subjective judgement,
which may also have to be adjusted over time as more experience with this
dataset is gained. Any feedback on this is most welcome.

Examples for `access` (all from California):

* Weed (US 97): yes — You can drive on a side street and access a gas station.
* Old Station (SR 44): yes — The highway takes you right through the town.
* Crestwood Summit (I-8): yes — You can drive over this summit.
* California Valley (SR 58): *probably* yes — There isn't much of a town along the highway, but maybe it just is that tiny.
* Kerman (SR 145): *probably* undefined — The limits of the town are entirely unclear, therefore it's impossible to say whether or not it's accessible.
* Malibu (SR 1): *probably* no — The town seems to be off the highway, past blockers.
* San Lucas (SR 198): no — You can drive past the town signs, but the actual town is entirely blocked off.
* Petaluma (US 101): no — There is no exit to leave the highway.
* Carlsbad (I-5): no — The exit off the highway is completely blocked.

### industry

    industry: boolean

Whether or not the label is for a game location with deliverable industry.
Typically, this will be the case for scenery towns with company depots
(sometimes called "suburbs").

This attribute can be true even when the industry in question is located
*outside* the signed limits of the town identified by the label. It depends
on the distance to the town and the general density of labels and features
in the given area.
Like for `access`, this requires some subjective judgement, which again may
have to be adjusted over time as more experience with this dataset is gained.
Any feedback on this is most welcome.

Examples for `industry` (all from California):

* Five Points (SR 145): yes — The [pecan farm](https://truckermudgeon.github.io?mlat=36.46&mlon=-120.09#8.5/36.46/-120.09) is *just* outside the town.
* Corning (I-5): *probably* yes — The [farm](https://truckermudgeon.github.io?mlat=39.9&mlon=-122.49#8.5/39.9/-122.49) is visible from the town limit sign, and there are no other named features anywhere close to it.
* Desert Lake (SR 58): *probably* no — The only access to the [industrial site](https://truckermudgeon.github.io?mlat=35.16&mlon=-117.59#8.5/35.16/-117.59) is past the town, but there's quite a bit of distance between them.
* California Valley (SR 58): no — The [quarry](https://truckermudgeon.github.io?mlat=35.34&mlon=-119.98#8.5/35.34/-119.98) in the area isn't close to the town at all.

### city

    city: string

The SCS token of the marked city this label can be *proven* to be associated
with, if any.

For towns, the usual way to prove such an association is the in-game economy;
see [`industry`](#industry).
Exceptionally, there may be other ways, such as "quick travel" targets.
Estimations based on geographical distance should not be considered for
this attribute (except as a part of assessing `industry`, if necessary).

### country

    country: string

The ISO 3166-1 code of the country (ETS2) or the ISO 3166-2 code of the
state or province (ATS) the labeled feature is located in.

Examples for `country`:

* Delaware: `US-DE`
* Germany: `DE`

### show

    show: boolean

Whether or not it's recommended to show this label by default on maps.

This attribute is an attempt to re-create the selection in the original
"ATS scenery towns" dataset. Its value is largely subjective, determined by
the dataset maintainer. Feedback is welcome.

If this attribute is missing for a label and there is no other information,
that label should be shown by default.

> [!TIP]  
> The `show` attribute will be missing frequently. Remember that you may
> have to check for the difference between an undefined value and the
> boolean fiction value, for example with JavaScript's `===` operator.

Examples for `show` (both from Kansas):

* Ashland (US 183): no — Not visible in the game, except on a distance sign.
* Protection (US 183): yes — Does exist in the game world (albeit inaccessible).

### checked

    checked: string

The ISO 8601 date of the last time the label was assessed for its metadata.
May be used in future to prioritize dataset maintenance. High precision isn't
necessary; the date formats `YYYY` or `YYYY-MM` should be adequate.

Checking / assessing usually requires looking at the in-game location using
the dev cam.

### ref

    ref: unknown

Reference to real-life information about the labeled entity.
Not currently used; reserved for future expansion.

The format isn't defined yet, but it'll probably be a string.
For example, the value could be a URI such as a Wikipedia link or
maybe a [GeoNames](https://www.geonames.org) record ID.

### remark

    remark: string

Any kind of note or comment about the label. Can be used to record sources or
rationale for metadata. There is no length limit for the remark, but long
remarks are less readable and should be avoided.

Can also be used to store additional data using micro-formats. For example, if
the remark of a mountain pass label begins with something like `8724ft`, it's
probably the pass elevation.
