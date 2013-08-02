#!/bin/bash

# first - conf name, second - users
function refactor_load(){
	perl -pi -e "s/\<stringProp name\=\"Argument\.value\">1000\<\/stringProp\>/\<stringProp name\=\"Argument\.value\">${2}\<\/stringProp\>/g" $1_$2U_10R_1000L_load.jmx
}
function refactor_peak(){
	perl -pi -e "s/\<stringProp name\=\"Argument\.value\">1000\<\/stringProp\>/\<stringProp name\=\"Argument\.value\">${2}\<\/stringProp\>/g" $1_$2U_2R_100L_peak.jmx
}

for i in 50 100 200 500 2000 
do
   cp $1_1000U_10R_1000L_load.jmx $1_${i}U_10R_1000L_load.jmx
   refactor_load $1 $i
   cp $1_1000U_2R_100L_peak.jmx $1_${i}U_2R_100L_peak.jmx 
   refactor_peak $1 $i  
done
