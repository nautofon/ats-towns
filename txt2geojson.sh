#! /bin/bash

if [ $# -ne 1 ]
then
  echo "Usage: $0 <path to state dir>"
  exit 1
fi

IN="$1/towns.txt"
OUT="$1/towns.geojson"

if [ ! -r "$IN" ]
then
  echo "$IN unreadable"
  exit 1
fi

TEMP=`mktemp` || exit 1


# Convert bugs.txt format to GeoJSON

awk 'BEGIN {FS=";";OFS=" "} {print $3,$5,$1}' "$IN" |

cct -c1,2 -z0 -t0 -d4 +proj=pipeline \
  +step +proj=axisswap +order=1,-2 \
  +step +inv +proj=lcc +lat_0=39 +lon_0=-96 +lat_1=33 +lat_2=45 +ellps=sphere +k_0=0.05088 |

# This projection definition is known to be inaccurate,
# but a more accurate definition is not known as of early 2023.
# The error is believed to be no higher than 0.1%.

while read -r x y z t name
do
  printf -v geometry '{"type":"Point","coordinates":[%s,%s]}' "$x" "$y"
  printf '{"type":"Feature","geometry":%s,"properties":{"name":"%s"}},\n' "$geometry" "$name"
done > "$TEMP"

echo '{"type":"FeatureCollection","features":[' > "$OUT"
sed -e '$s/.$//' "$TEMP" >> "$OUT"
echo ']}' >> "$OUT"

rm -f "$TEMP"
