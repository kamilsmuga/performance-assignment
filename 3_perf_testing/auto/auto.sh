#!/bin/bash

JBOSS_DIR=/home/comp40010/jboss-5.0.1.GA/
JMETER_DIR=/home/comp40010/apache-jmeter-2.9_client/bin/
TEST_PLANS=/home/ks/
MASTER='jmeter-master'

# start jboss
function start_jboss () {
	nohup sh $JBOSS_DIR/bin/run.sh -b 0.0.0.0 &>/dev/null </dev/null  &
	sleep 60
}

# get jboss pid
function get_jboss_pid () {
	JBOSS_PID=`ps -ef | grep run.sh | grep java | grep -v grep | awk '{print $2}'`
}

# attach visualvm to jboss
function attach_visualvm () {
	nohup jvisualvm --openpid $JBOSS_PID &>/dev/null </dev/null &
}

# kick off jmeter tests remotely via CLI
# takes 2 arguments: jmeter plan location and output file location
function start_remote_jmeter () {
	ssh ks@$MASTER "cd ${JMETER_DIR} ; java -jar ApacheJMeter.jar -n -r -t $1 -l $2"
	scp ks@$MASTER:$2 .
}

# stop jboss
function stop_jboss () {
	kill $JBOSS_PID
	sleep 60
	kill -9 $JBOSS_PID
}

# attach visualvm
function attach_visualvm () {
	jvisualvm --nosplash --openpid $JBOSS_PID
}

# get GC logs
function get_gc_logs () {
	mv $JBOSS_DIR/bin/gc* .
}

# main loop function
function main () {
	cd $TEST_PLANS
	for f in *; do
    	   echo $f
	done
}


main
#get load testing logs

#start_remote_jmeter
#warmup jboss
#sleep 300

#
function test () {
while true ; do 
   sleep 5
   echo "iterating"
   grep "Started in" $JBOSS_DIR/server/default/log/boot.log
   if [ $? -eq 0 ]; then
      break
   fi
done
}


