#!/bin/bash

JBOSS_DIR=/home/comp40010/jboss-5.0.1.GA/

function setXmsAndXmxEqual () {
	cp $JBOSS_DIR/bin/run.conf $JBOSS_DIR/bin/run.conf.backup
	perl -pi -e 's/\-Xms128m \-Xmx512m/\-Xms512m \-Xmx512m/g' $JBOSS_DIR/bin/run.conf
}

function useParallelGC () { 
	cp $JBOSS_DIR/bin/run.conf $JBOSS_DIR/bin/run.conf.backup
	perl -pi -e 's/HeapDumpOnOutOfMemoryError/HeapDumpOnOutOfMemoryError \-XX\:\+UseParallelGC \-XX\:ParallelGCThreads\=2/g' $JBOSS_DIR/bin/run.conf
}

function heapRatio () {
	cp $JBOSS_DIR/bin/run.conf $JBOSS_DIR/bin/run.conf.backup
	perl -pi -e 's/HeapDumpOnOutOfMemoryError/HeapDumpOnOutOfMemoryError \-XX\:NewSize=170m \-XX\:NewRatio=2/g' $JBOSS_DIR/bin/run.conf
}

function threadPoolSize () {
	cp $JBOSS_DIR/server/default/conf/jboss-service.xml $JBOSS_DIR/server/default/conf/jboss-service.xml.backup
        perl -pi -e 's/\<attribute name=\"MaximumPoolSize\"\>10\<\/attribute\>/\<attribute name=\"MaximumPoolSize\"\>50\<\/attribute\>/g' $JBOSS_DIR/server/default/conf/jboss-service.xml
}

function disableHotDeploy () {
	mv $JBOSS_DIR/server/default/deploy/hdscanner-jboss-beans.xml /tmp/
}
function enableHotDeploy () { 
	mv /tmp/hdscanner-jboss-beans.xml $JBOSS_DIR/server/default/deploy/
}

function disableConsoleAppender () {
	cp $JBOSS_DIR/server/default/conf/jboss-log4j.xml $JBOSS_DIR/server/default/conf/jboss-log4j.xml.backup
	cp jboss-log4j.xml_no_console $JBOSS_DIR/server/default/conf/jboss-log4j.xml
}

function increaseThreadLocalPool () {
	cp $JBOSS_DIR/server/default/deploy/ejb3-interceptors-aop.xml $JBOSS_DIR/server/default/deploy/ejb3-interceptors-aop.xml.backup 
	perl -pi -e 's/value=\"ThreadlocalPool\", maxSize=30/value=\"ThreadlocalPool\", maxSize=100/g' $JBOSS_DIR/server/default/deploy/ejb3-interceptors-aop.xml
}

function increaseStrictMaxPool () {
	cp $JBOSS_DIR/server/default/deploy/ejb3-interceptors-aop.xml $JBOSS_DIR/server/default/deploy/ejb3-interceptors-aop.xml.backup
	perl -pi -e 's/value=\"StrictMaxPool\", maxSize=15/value=\"StrictMaxPool\", maxSize=50/g' $JBOSS_DIR/server/default/deploy/ejb3-interceptors-aop.xml
}

disableHotDeploy
disableConsoleAppender
increaseThreadLocalPool
increaseStrictMaxPool
threadPoolSize
heapRatio
useParallelGC
setXmsAndXmxEqual
