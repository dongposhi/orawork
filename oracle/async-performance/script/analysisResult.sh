#!/bin/bash

INSTANCES="10 20 30 40 50 60 70 80 90"
THREADS="10 30 50 70 90 110 130 150 170"

sum=ax
echo "threads" > ${sum}
for i in `echo ${THREADS}`
do
    echo "${i}" >> ${sum}
done

for i in `echo ${INSTANCES}`
do
    echo "threads instance=${i}" > /tmp/_instance_${i}
    grep 'Average' testresult_*_${i} | sed "s/testresult_\(.*\)_${i}.*:\(.*\)\..*/\1 \2/"|sort -n >>/tmp/_instance_${i}
    join ${sum} /tmp/_instance_${i} > /tmp/sum2
    cp /tmp/sum2 ${sum}
done

