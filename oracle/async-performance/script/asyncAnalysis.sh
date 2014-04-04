#!/bin/bash
SOURCE_FILE=/scratch/doshi/workspace/1214/itest/jrf-ws-qa-tests/target/wsDomain/jrfServer_admin.out

T1=a1
T2=a2

T3=a3
T4=a4

T5=a5
T6=a6

T7=a7
T8=a8

TSUM=asum
TSUM2=asum2

grep @sdp $SOURCE_FILE > tt
SOURCE_FILE=tt

#grep 'AsyncServiceRuntimeDelegate' $SOURCE_FILE |grep receive |sed 's/.*\(messageId=.*\) on \(.*\)/\1 \2 /'|sort -k2n|sed -n '1801,2700p' |sort > $T1
grep 'AsyncServiceRuntimeDelegate' $SOURCE_FILE |grep receive |sed 's/.*\(messageId=.*\) on \(.*\)/\1 \2 /'|sort > $T1
grep 'AsyncServiceRuntimeDelegate' $SOURCE_FILE |grep send    |sed 's/.*\(messageId=.*\) on \(.*\)/\1 \2 /'|sort > $T2


grep 'NonAnonymouse' $SOURCE_FILE |grep receive |sed 's/.*\(messageId=.*\) on \(.*\)/\1 \2 /'|sort > $T3
grep 'NonAnonymouse' $SOURCE_FILE |grep 'send ' |sed 's/.*\(messageId=.*\) on \(.*\)/\1 \2 /'|sort > $T4

grep MDB $SOURCE_FILE | grep equest| grep receive|sed 's/.*message (\(.*\)) on \(.*\)/messageId=\1) \2/'|sort  > $T5
grep MDB $SOURCE_FILE | grep equest| grep finish|sed 's/.*message (\(.*\)) on \(.*\)/messageId=\1) \2/'|sort  > $T6

grep MDB $SOURCE_FILE | grep esponse| grep receive|sed 's/.*message (\(.*\)) on \(.*\)/messageId=\1) \2/'|sort  > $T7
grep MDB $SOURCE_FILE | grep esponse| grep finish|sed 's/.*message (\(.*\)) on \(.*\)/messageId=\1) \2/'|sort  > $T8

join $T1 $T2 >/tmp/$T2
join /tmp/$T2 $T3 >/tmp/$T3
join /tmp/$T3 $T4 >/tmp/$T4
join /tmp/$T4 $T5 >/tmp/$T5
join /tmp/$T5 $T6 >/tmp/$T6
join /tmp/$T6 $T7 >/tmp/$T7
join /tmp/$T7 $T8 >/tmp/$T8

cp /tmp/$T8 $TSUM

#  list fields as time order
#
# $1: messageID
# $2: AysncServiceRuntimeDelegate.received msg
# $3: AysncServiceRuntimeDelegate.send msg to Request Queue
# $6: enter Request MDB onMessage
# $7: exit Request MDB onMessage
# $8: enter Response MDB onMessage
# $4: NonAnonymouseResponseHandler.received msg
# $5: NonAnonymouseResponseHandler.finish msg
# $9: exit Response MDB onMessage
# 
# $3-$2: AsyncServiceRuntimeDelagte process the msg 
# $6-$3: message hold by request queue
# $7-$6: message hold by request MDB
# $8-$7: message hold by response queue
# $9-$8: message hold by response MDB ( include invocation of callback
# $9-$2: message hold by server side
awk '{printf("%s %7d %7d %7d %7d %7d %7d\n",$1,$3-$2 ,$6-$3,$7-$6,$8-$7,$9-$8,$9-$2)}' $TSUM > $TSUM2
#awk '{printf("%s %7d %7d %7d %7d %7d %7d %7d\n",$1,$3-$2 ,$4-$3,$5-$4,$6-$5,$7-$6,$8-$7,$9-$8)}' $TSUM > $TSUM2

rm /tmp/$T2 /tmp/$T3 /tmp/$T4 /tmp/$T5 /tmp/$T6 /tmp/$T7 /tmp/$T8
