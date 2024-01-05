#!/bin/sh

cd $1
find . -type l -not -path '*/renv/*' -ls | awk '{print $14}' | grep "^/" | sort -u | xargs | sed 's/ /,/g'
