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
      -e "s/(\"properties\":{)/\1\"state\":\"$state_id\",\"country\":\"US-$state_id\",/" \
      -e "s/\"name\":(\".*\")/\"name\":\1,\"text\":\1/" \
      -e "/0+(,|\])/s//\1/g" \
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

awk 'BEGIN {FS=";";OFS=" "} {print $3,$5,"0",$1}' "$IN" |

cs2cs -d 4 \
  "$( curl -LSs https://nautofon.github.io/scs-crs/wkt-ats.txt )" \
  "urn:ogc:def:crs:OGC:1.3:CRS84" |

while read -r x y z name
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
