#! /bin/bash

if [ $# -ne 1 ]
then
  echo "Usage: $0 <path to state dir>|all"
  exit 1
fi

temp_to_geojson () {
  temp="$1"
  json="$2"
  echo '{"type":"FeatureCollection","features":[' > "$json"
  sed -e '$s/.$//' "$temp" >> "$json"
  echo ']}' >> "$json"
  rm -f "$temp"
}

if [ "$1" = "all" ]
then
  TEMP=`mktemp` || exit 1
  DIR=`dirname "$0"`
  find "$DIR" -regex "$DIR/[A-Z][A-Z]/towns.geojson" |
  sed -e 's/.*\(..\).towns.geojson$/\1/' | sort |
  while read -r state_id
  do
    sed -E -e '1d; $d; s/,?$/,/' \
      -e "s/(\"properties\":{)/\1\"state\":\"$state_id\",/" \
      "$DIR/$state_id/towns.geojson" >> "$TEMP"
  done
  temp_to_geojson "$TEMP" "$DIR/all-towns.geojson"
  exit 0
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
# The error is believed to be no higher than 0.4%.

while read -r x y z t name
do
  printf -v geometry '{"type":"Point","coordinates":[%s,%s]}' "$x" "$y"
  printf '{"type":"Feature","geometry":%s,"properties":{"name":"%s"}},\n' "$geometry" "$name"
done > "$TEMP"

if [ `wc -l "$IN" | awk '{print $1}'` -ne `wc -l "$TEMP" | awk '{print $1}'` ]
then
  echo "Converting '$IN' using '`which cct`' failed."
  rm -f "$TEMP"
  exit 1
fi

temp_to_geojson "$TEMP" "$OUT"
