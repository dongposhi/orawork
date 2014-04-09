#!/bin/bash

CMD1=/scratch/doshi/workspace/sdp/oracle/async-performance/script/asyncAnalysis.sh

instances="10 20 30 40 50 60 70 80 90"
threads="10 30 50 70 90 110 130"

RESULT_FILE=avr

touch ${RESULT_FILE}
cp /dev/null ${RESULT_FILE}
for thread in `echo ${threads}`
do
    for instance in `echo ${instances}`
    do
        TARGET=/scratch/doshi/tmp/jrfServer_admin.out_${thread}_${instance}

        ${CMD1} ${TARGET}

        result=`awk '{sum3+= $3; sum5+=$5} END {print sum3/NR,sum5/NR}' asum2`
        echo "${thread} ${instance} ${result}">>${RESULT_FILE}
    done
done
