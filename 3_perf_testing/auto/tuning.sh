#!/bin/bash

JBOSS_DIR=/home/comp40010/jboss-5.0.1.GA/

function 1_setXmsAndXmxEqual () {
	cp $JBOSS_DIR/bin/run.conf $JBOSS_DIR/bin/run.conf.backup
	perl -pi -e "s/\-Xms128m \-Xmx512m/\-Xms512m \-Xmx512m/g" $JBOSS_DIR/bin/run.conf
}
