#!/bin/bash

i=60
MAX=100

FILE1='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/build.xml'
FILE2='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/src/client/com/oracle/webservices/jaxws/test/j2wpojoasync/AsyncEjbTest.java'

THREAD=10
MAX_THREAD=100

while [ $i -lt $MAX ]
do
    j=$((i*2))
    sed -i "250,270s/messageProcessorInitialPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorInitialPoolSize = $i/" $FILE1
    sed -i "250,270s/messageProcessorMaxPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorMaxPoolSize = $i/" $FILE1
    sed -i "270,280s/messageProcessorInitialPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorInitialPoolSize = $j/" $FILE1
    sed -i "270,280s/messageProcessorMaxPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorMaxPoolSize = $j/" $FILE1

    while [ $THREAD -lt $MAX_THREAD ]
    do
        sed -i "s/int threads = [1-9]\+\([0-9]*\)*/int threads = $THREAD/" $FILE2
        ant -f asyncejb.test.xml run  -DAQ_JMS=false > /scratch/doshi/tmp/testresult_${THREAD}_${i}
        THREAD=$((THREAD+10))
    done
    i=$((i+10))
done
