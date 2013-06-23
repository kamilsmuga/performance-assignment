mkdir $1
cd $1
mv /tmp/visualvm.dat/localhost_${2}/heapdump-* . 
read -p "Press [Enter] key to if jboss is down"
mv /home/comp40010/jboss-5.0.1.GA/bin/gc.log.* .
