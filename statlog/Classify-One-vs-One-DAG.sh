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
     CL=1; i=1;
     for (ca=1; ca <= NC; ++ca) {
       for (cb=ca+1; cb <= NC; ++cb) {
         if (ca == CL && cb > CL) {
           if ($i > 0) { CL=ca; } else { CL=cb; }
         }
         ++i;
       }
     }
     print CL
   }
}'
