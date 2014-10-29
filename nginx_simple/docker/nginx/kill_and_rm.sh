#!/bin/bash

set -eu

if [ $(whoami) != "root" ]; then
    echo root only >&2
    exit 1
fi

for cid in $(find $(pwd) -maxdepth 1 -name "*.cid" -type f)
do
    docker -H="0.0.0.0:5422" rm -f $(cat ${cid})
    rm -f ${cid}
done

exit
