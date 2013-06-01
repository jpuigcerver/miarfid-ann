#!/bin/bash
set -e

while [ "${1:0:1}" = "-" ]; do
    case "$1" in
        -c)
            NC=$2; shift 2;
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
    esac
done

[ "$NC" = "" ] && {
    echo "You mush indicate the number of classes. Use -c option." >&2
    exit 1
}

awk -v NC=$NC '{
   if (NF == NC * (NC-1)/2) {
   for (ca=1; ca <= NC; ++ca) { V[ca]=0; }
   i=1;
   for (ca=1; ca <= NC; ++ca) {
     for (cb=ca+1; cb <= NC; ++cb) {
       if ($i > 0) { V[ca]++; } else { V[cb]++; }
       ++i;
     }
   }
   CL=1; msc=V[1];
   for (c=2; c <= NC; ++c) {
     if (V[c] > msc) { msc=V[c]; CL=c; }
   }
   print CL
   }
}'

exit 0
