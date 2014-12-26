#!/bin/bash

THREADS="10 30 50 70 90 110 130 150"
#INSTANCES="10 20 30 40 50 60 70 80 90"
INSTANCES="1 3 5 7 "

FILE1='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/src/ejb/com/oracle/webservices/jaxws/test/AsyncEjb.java'

FILE2='/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/wstest/webservices/test/tsrc/ws/jaxws/asyncejb/src/client/com/oracle/webservices/jaxws/test/j2wpojoasync/AsyncEjbTest.java'

FILE3="/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/target/wsDomain/jrfServer_admin.out"

CMD1="ant -f asyncejb.test.xml  clean build prepare startup -DAQ_JMS=false -Dwls.spawn=true -Dportability.utpenv.file=/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/target/utpenv.properties -Denv.configured=true  -Djrf.domain.type=singleton -Dasync-template-required=true"

CMD2="ant -f asyncejb.test.xml run  -DAQ_JMS=false" 

${CMD1}

i=aq
for j in `echo ${THREADS}`
do
   sed -i "s/int threads = [1-9]\+\([0-9]*\)*/int threads = ${j}/" $FILE2
   cp /dev/null ${FILE3}
   ${CMD2} > /scratch/doshi/tmp/testresult_${j}_${i}
   cp ${FILE3} /scratch/doshi/tmp/jrfServer_admin.out_${j}_${i}
done
