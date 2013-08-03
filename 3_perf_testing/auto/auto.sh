#!/bin/bash

JBOSS_DIR=/home/comp40010/jboss-5.0.1.GA/
JMETER_DIR=/home/comp40010/apache-jmeter-2.9_client/bin/
TEST_PLANS=/home/comp40010/performance-assignment/3_perf_testing/auto/test_plans/test
MASTER='jmeter-master'

# start jboss
function start_jboss () {
	echo "Starting jboss..."
	nohup sh $JBOSS_DIR/bin/run.sh -b 0.0.0.0 &>/dev/null </dev/null  &
	echo "Sent start signal. Waiting 60 secs to boot"
	sleep 60
	echo "start_jboss() finished"
}

# get jboss pid
function get_jboss_pid () {
	JBOSS_PID=`ps -ef | grep run.sh | grep java | grep -v grep | awk '{print $2}'`
}


function attach_visualvm () {
	echo "Attaching visualvm to jboss process with pid ${JBOSS_PID}"
	nohup sh /home/comp40010/performance-assignment/3_perf_testing/auto/visual.sh ${JBOSS_PID} &	
	echo "attach_visualvm() finished"
}

# kick off jmeter tests remotely via CLI
# takes 2 arguments: jmeter plan location and output file location
function start_remote_jmeter () {
	echo "Starting remote test plan with jmeter"
	echo "Preparing output dir $3 on $MASTER"
	ssh ks@$MASTER "mkdir -p ${JMETER_DIR}/$3"
	echo "Copying $1 to $MASTER"
	scp $1 ks@$MASTER:$JMETER_DIR/$3
	echo "Executing jmeter remote test plan on $MASTER"
	ssh ks@$MASTER "cd ${JMETER_DIR} ; java -jar ApacheJMeter.jar -n -r -t $3/$1 -l $3/$2"
	echo "Copying back results from test plan" 
	scp ks@$MASTER:${JMETER_DIR}/$3/$2 $3
	echo "start_remote_jmeter() finished"
}

# stop jboss
function stop_jboss () {
	echo "Stopying jboss..."
	kill $JBOSS_PID
	sleep 60
	kill -9 $JBOSS_PID
	echo "stop_jboss() finished"
}

# get GC logs
function get_gc_logs () {
	echo "Copying GC logs to $1"
	mv $JBOSS_DIR"/bin/gc*" $1
	mv gc* $1
	echo "get_gc_logs() finished"
}
# generate graphs from jmeter results
function generate_jmeter_graphs () {
	OUT=$JMETER_DIR/$2
	echo "Generating ResponseTimesOverTime graph from results $1"
	ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_response_times_over_time.png --input-jtl $OUT/$1 --plugin-type ResponseTimesOverTime --width 800 --height 600 "
	echo "Generating Active Threads Over Time graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_active_threads_over_time.png --input-jtl $OUT/$1 --plugin-type ThreadsStateOverTime --width 800 --height 600 "
	
	echo "Generating BytesThroughputOverTime graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_bytes_throughput_over_time.png --input-jtl $OUT/$1 --plugin-type BytesThroughputOverTime --width 800 --height 600 "
	
	echo "Generating HitsPerSecond graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_hits_per_second.png --input-jtl $OUT/$1 --plugin-type HitsPerSecond --width 800 --height 600 "

	echo "Generating LatenciesOverTime graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_latencies_over_time.png --input-jtl $OUT/$1 --plugin-type LatenciesOverTime --width 800 --height 600 "

	echo "Generating ResponseTimesDistribution graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_response_times_distribution.png --input-jtl $OUT/$1 --plugin-type ResponseTimesDistribution --width 800 --height 600 "

	echo "Generating ResponseTimesOverTime graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_response_times_over_time.png --input-jtl $OUT/$1 --plugin-type ResponseTimesOverTime --width 800 --height 600 "

	echo "Generating ThroughputOverTime graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_throughput_over_time.png --input-jtl $OUT/$1 --plugin-type ThroughputOverTime --width 800 --height 600 "

	echo "Generating ThroughputVsThreads graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_throughput_vs_threads.png --input-jtl $OUT/$1 --plugin-type ThroughputVsThreads --width 800 --height 600 "

        echo "Generating TimesVsThreads graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_times_vs_threads.png --input-jtl $OUT/$1 --plugin-type TimesVsThreads --width 800 --height 600 "

        echo "Generating TransactionsPerSecond graph from results $1"
        ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-png $OUT/$1_transactions_per_second.png --input-jtl $OUT/$1 --plugin-type TransactionsPerSecond --width 800 --height 600 "

	
	echo "Generating summary report in CSV"
	ssh ks@$MASTER "cd ${JMETER_DIR}/../lib/ext/ ; java -jar CMDRunner.jar --tool Reporter --generate-csv $OUT/$1_summary_report.csv --input-jtl $OUT/$1 --plugin-type AggregateReport"

	echo "Copying generated graphs $1.png to $2"
	scp ks@$MASTER:$OUT/*.png $2
}

# main loop function
function main () {
	cd $TEST_PLANS
	for f in *.jmx; do
	   OUT=output/$f"_"`date +"%Y-%m-%d-%H:%M"`
	   mkdir -p $OUT
	   start_jboss
	   get_jboss_pid
	   attach_visualvm
	   # warmup jboss
	   sleep 180
	   start_remote_jmeter $f $f.out $OUT
	   generate_jmeter_graphs $f.out $OUT
	   stop_jboss
	   get_gc_logs $OUT
    	   echo $f
	done
}

function test () {
	cd $TEST_PLANS
	for f in *.jmx; do
	   OUT=output/$f"_"`date +"%Y-%m-%d-%H:%M"`
	   mkdir -p $OUT
	   # warmup jboss
#	   start_jboss
	   get_jboss_pid
	   attach_visualvm
	   start_remote_jmeter $f $f.out $OUT
	   generate_jmeter_graphs $f.out $OUT
	   #stop_jboss
    	   #echo $f
	done
}

test
#main
# TODO: get jmeter-server logs
