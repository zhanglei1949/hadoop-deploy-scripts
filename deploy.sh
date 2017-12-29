#!/bin/bash

#action=$1

usage(){
	echo "This scripts is used to deploy hadoop/hive/spark/ on bare metal"
	echo "./deploy.sh	[-j] installjava"
	echo "		  	[-c] for common"
	echo "		  	[-p] for hadoop common"
	echo "			[-h] for hive"
	echo "			[-s] s for spark"
	echo "			[-m] for maven"
	echo "			[-t] for hive-testbench"
	echo "			[-r] for presto"
	echo "			[-a] to enable s3a"
	echo " If not specified, all are set false"
	exit 1
}
format_disks()
{
	echo formating disks now

}


install_java=false
install_common=false
install_hadoop_common=false
install_hive=false
install_spark=false
install_maven=false
install_hive_testbench=false
install_presto=false
with_s3a=0
#echo $#
#if no parameters provide, print out usage

if [ $# -eq 0 ];
then
	usage
fi
#Parsing the commands
while getopts "jcphsmtra" opt;
do
	case $opt in 
	j)
		echo "install java"
		install_java=yes
		;;
	c)
		echo "install common"
		install_common=yes
		;;
	p)
                echo "install hadoop common"
                install_hadoop_common=yes
		;;
	h)
                echo "install hive"
                install_hive=yes
		;;
	s)
                echo "install spark"
                install_spark=yes
		;;
	m)
                echo "install maven"
                install_maven=yes
		;;
	t)
                echo "install hive-testbench"
                install_hive_testbench=yes
		;;
	r)
                echo "install presto"
                install_presto=yes
		;;
	a)
                echo "with s3a"
                with_s3a=1
                ;;
	\?)
		echo "invalid opition: $OPTARG"
		usage
		exit 1
		;;
	esac
done


# first check whether hadoop is running on each server, and shut them down
echo "***********************************************************************"
echo  first check whether hadoop is running on each server, and shut them down
servers=(client1)
for server in $servers;
do
	echo $server
	ssh $server jps
	ssh $server /hadoop/sbin/stop-all.sh
done
# get the date

# Secondly umount all using  disks
echo "***********************************************************************"
echo Secondly umount all using  disks
 
for server in $servers;
do
	echo "umounting disks on"$server
	disks=`ssh $server df | grep hadoop |awk '{print $1}'`
	umount $disks
	echo $disks
done

# Thirdly rename the hadoop directory to a unique name
echo "***********************************************************************"
echo Thirdly rename the hadoop directory to a unique name

if [ -d "/hadoop" ];
then
	hadoop_version = `hadoop version | grep Hadoop | awk '{print $2}'`
	echo $hadoop_version
	back_up_dir="/hadoop-"${hadoop_version}"-"`date +%Y-%m-%d`
	echo $back_up_dir
	if [ -d $back_up_dir ];
	then
		i=0
		while [ -d ${back_up_dir}"-"${i} ]
		do
			echo ${back_up_dir}"-"${i}
			i=$[i+1]
		done
		back_up_dir=${back_up_dir}"-"${i}
	fi
	echo $back_up_dir

	for server in $servers;
	do
		echo "mv /hadoop to $back_up_dir"
		mv /hadoop $back_up_dir 
	done

fi

# Forthly, run ansible-playbook deployment
echo "***********************************************************************"
cmd="ansible-playbook -i hosts"
if [ $with_s3a -eq 1 ];
then
	echo "with s3a support, using file site-s3a"
	
	cmd=$cmd" site-s3a.yaml "
else
	
	echo "without s3a"
	cmd=$cmd" site-without-s3a.yml"
fi

cmd=$cmd" --extra-vars '{\"install_java\":\"$install_java\",\"install_common\":\"$install_common\", \"install_hadoop_common\":\"$install_hadoop_common\",  \"install_hive\":\"$install_hive\",\"install_spark\":\"$install_spark\", \"install_maven\":\"$install_maven\",\"install_hive_testbench\":\"$install_hive_testbench\", \"install_presto\":\"$install_presto\"}'"
echo $cmd
`$cmd`

