#!/bin/bash

#i=60
#MAX=100

#FILE1='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/build.xml'
#FILE2='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/src/client/com/oracle/webservices/jaxws/test/j2wpojoasync/AsyncEjbTest.java'

#THREAD=10
#MAX_THREAD=100

#while [ ${i} -lt $MAX ]
#do
    #j=$((i*2))
    #sed -i "250,270s/messageProcessorInitialPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorInitialPoolSize = ${i}/" $FILE1
    #sed -i "250,270s/messageProcessorMaxPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorMaxPoolSize = ${i}/" $FILE1
    #sed -i "270,280s/messageProcessorInitialPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorInitialPoolSize = $j/" $FILE1
    #sed -i "270,280s/messageProcessorMaxPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorMaxPoolSize = $j/" $FILE1

    #while [ $THREAD -lt $MAX_THREAD ]
    #do
        #sed -i "s/int threads = [1-9]\+\([0-9]*\)*/int threads = $THREAD/" $FILE2
        #ant -f asyncejb.test.xml run  -DAQ_JMS=false > /scratch/doshi/tmp/testresult_${THREAD}_${i}
        #THREAD=$((THREAD+10))
    #done
    #i=$((i+10))
#done


THREADS="30 50 70 90"
INSTANCES="50"


AQ_JMS=false

FILE1='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/src/ejb/com/oracle/webservices/jaxws/test/AsyncEjb.java'

FILE2='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/src/client/com/oracle/webservices/jaxws/test/j2wpojoasync/AsyncEjbTest.java'

FILE3="/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/target/wsDomain/jrfServer_admin.out"

#CMD1="ant -f asyncejb.test.xml  clean build prepare startup -DAQ_JMS=${AQ_JMS} -Dwls.spawn=true -Dportability.utpenv.file=/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/target/utpenv.properties -Denv.configured=true  -Djrf.domain.type=singleton"
CMD1="ant -f asyncejb.test.xml  startup -DAQ_JMS=${AQ_JMS} -Dwls.spawn=true -Dportability.utpenv.file=/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/target/utpenv.properties -Denv.configured=true  -Djrf.domain.type=singleton"

CMD2="ant -f asyncejb.test.xml run  -DAQ_JMS=${AQ_JMS}" 

#${CMD1}
for i in `echo ${INSTANCES}`
do
#    sed -i "65,75s/messageProcessorInitialPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorInitialPoolSize = ${i}/"  ${FILE1}
    #sed -i "65,75s/messageProcessorMaxPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorMaxPoolSize = ${i}/" $FILE1
    #sed -i "110,120s/messageProcessorInitialPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorInitialPoolSize = ${i}/"  ${FILE1}
    #sed -i "110,120s/messageProcessorMaxPoolSize = [1-9]\+\([0-9]*\)*/messageProcessorMaxPoolSize = ${i}/" $FILE1

    if [ "${AQ_JMS}" == "true" ];then
        sed "s/_INSTANCES_/$i/" /scratch/doshi/workspace/sdp/oracle/async-performance/script/aq-ejb-jar.xml >/scratch/doshi/tmp/aq-ejb-jar.xml
    else
        sed "s/_INSTANCES_/$i/" /scratch/doshi/workspace/sdp/oracle/async-performance/script/weblogic-ejb-jar.xml >/scratch/doshi/tmp/weblogic-ejb-jar.xml
    fi

    for j in `echo ${THREADS}`
    do
        if [ "${AQ_JMS}" == "true" ];then
            suffix="${j}_${i}_aq"
        else
            suffix="${j}_${i}"
        fi
        sed -i "s/int threads = [1-9]\+\([0-9]*\)*/int threads = ${j}/" $FILE2
        cp /dev/null ${FILE3}
        ${CMD2} > /scratch/doshi/tmp/testresult_${suffix}
        cp ${FILE3} /scratch/doshi/tmp/jrfServer_admin.out_${suffix}
    done
done
